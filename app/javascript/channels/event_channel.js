import consumer from "./consumer";

const initEventCable = () => {
  const technicalContainer = document.getElementById("technical");
  if (technicalContainer) {
    const id = technicalContainer.dataset.eventId;

    consumer.subscriptions.create(
      { channel: "EventChannel", id: id },
      {
        received(data) {
          console.log(data); // called when data is broadcast in the cable
        },
      }
    );
  }
};

export { initeventCable };
