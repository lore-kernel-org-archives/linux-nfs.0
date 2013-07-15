Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:48029 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab3GOPaQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Jul 2013 11:30:16 -0400
Received: by mail-ie0-f170.google.com with SMTP id e11so26528095iej.15
        for <linux-nfs@vger.kernel.org>; Mon, 15 Jul 2013 08:30:16 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 15 Jul 2013 08:30:15 -0700
Message-ID: <CAAgPx6QTC2-92mmSjAuH-bK-dhSJdYNi3QqOrmgtM8ZvpKE+Mg@mail.gmail.com>
Subject: multiple threads to service a single nfs client connection?
From: Ravi Murty <ravi.murty@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello All,

I've been working on trying to send multiple requests in parallel from
an NFS client over UDP to a server. We're working on improving the
performance of NFS on our little core with lots of threads. Given this
environment, my goal is to send rpc tasks over UDP from more than one
thread at the same time. To do this, I take advantage of some of the
code changes made in the TX path that allow the sending of RPC packets
without having to cork the socket when MSG_MORE is false. With this
change, I don't have to lock the transport allowing me to send
rpc_tasks from multiple threads at the same time (there is some
serialization in the driver down below, but that seems okay).

Without this change (requests are sent out serially one after another)
the server gets a request, formulates a reply (my file is probably
cached on the server) and sends out a response in anywhere between 40
and 90 microseconds. It then sees the next request and so on.

With this change, the client is able to "flood" the server with a lot
of requests very quickly (they arrive about 10-15 microseconds apart).
The responses to the clients request get delayed and in some cases the
response gets delayed by 800 microseconds.

Is there a way to increase the number of threads that service a single
client connection?

Thanks
