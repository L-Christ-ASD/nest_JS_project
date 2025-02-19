FROM node:latest AS base

WORKDIR /app
COPY ./package.json ./
RUN npm install
COPY ./ ./


FROM base As developpement

CMD ["npm", "run", "start:dev", "--", "--host", "0.0.0.0"]


FROM base As build

RUN npm run build


FROM node:lts-alpine As production

WORKDIR /app
COPY --from=build /app/dist ./dist
COPY ./package.json ./
RUN npm install --omit=dev --production
CMD [ "node", "dist/main" ]


FROM node:lts-alpine As server

COPY --from=production /app/dist /usr/share/nginx/html




