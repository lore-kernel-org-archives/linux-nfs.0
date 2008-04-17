From: "Usman S. Ansari" <usman.ansari@yahoo.com>
Subject: RPC Question
Date: Thu, 17 Apr 2008 13:57:29 -0700 (PDT)
Message-ID: <969249.1309.qm@web50508.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web50508.mail.re2.yahoo.com ([206.190.38.84]:20553 "HELO
	web50508.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753437AbYDQVEL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Apr 2008 17:04:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, I am modifying Linux sunrpc code to work with TOE (TCP offload engine). I have a question about tcp_data_recv function.

What does flags XPRT_COPY_RECM, XPRT_COPY_XID & XPRT_COPY_DATA mean ? and where can I get description of tcp_read_fraghdr, tcp_read_xid and tcp_read_request.

If there is any sort of documentaion or flow please let me know.

Thanks

Usman
