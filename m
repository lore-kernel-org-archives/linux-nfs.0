Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f193.google.com ([209.85.192.193]:33525 "EHLO
	mail-pd0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaANCDb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jan 2014 21:03:31 -0500
Received: by mail-pd0-f193.google.com with SMTP id y10so655713pdj.4
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jan 2014 18:03:30 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 14 Jan 2014 10:03:29 +0800
Message-ID: <CALrKORpD5MLWCEfa-jeXmrGCF5nNVi8LVZC_tG-FWfBoRo6+sw@mail.gmail.com>
Subject: What caused the rpc_rqst unable to be obtained in xs_tcp_read_callback?
From: shaobingqing <shaobingqing@bwstor.com.cn>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In the function xs_tcp_read_callback, when the rpc_rqst are unable to
be obtained, the connection will be closed and the system will give a
KERN_WARNING "Callback slot table overflowed". We know that although
there is only one rpc_rqst is prealloced, metadata server cannot send
two or more callback requests to one client at the  same time, because
there is only one slot on the metadate server for the client.

Now, in my test, the KERN_WARNING "Callback slot table overflowed"
always occurs. So, I want to know that what caused the rpc_rqst unable
to be obtained. Maybe there are retransmissions in the systems.

Are there anybody can expain the reason for us?
