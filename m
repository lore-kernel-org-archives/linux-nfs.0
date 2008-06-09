From: "Marcelo Leal" <diversos-roWltSPQdMkZWYhx5MAOMFAUjnlXr6A1@public.gmane.org>
Subject: nfsd: accept failed (err 22)
Date: Sun, 8 Jun 2008 21:07:02 -0300
Message-ID: <42996ba90806081707i183f8373h1304681dab79db63@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:48382 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754971AbYFIAHG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jun 2008 20:07:06 -0400
Received: by wf-out-1314.google.com with SMTP id 27so1859080wfd.4
        for <linux-nfs@vger.kernel.org>; Sun, 08 Jun 2008 17:07:02 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 Ok, Ok, it's an old GNU/Linux kernel(2.4.20), but it was working
pretty well for years! Just strong as a rock.
 Now, after seeing the message:

 nfsd: accept failed (err 22)!

 in the logs, some clients start to behave very bad (slow)... most
some rhel tcp clients!
 I think that can be a "tcp" problem, maybe some problem in the network.
 Looking the code:
...
if (tcpflag && FD_ISSET(tcpsock, ready)) {
 			len = sizeof(inetpeer);
 			if ((msgsock = accept(tcpsock,
  			    (struct sockaddr *)&inetpeer, &len)) < 0) {
  				syslog(LOG_ERR, "accept failed: %m");
   				return (1);
...
Seems like after restart the server, everything goes fine.
I just want to ask you the following:

1) Am i right, that is a problem with the "tcp" connections?
2) it's a bug in the NFS server (probably solved in newer versions),
or it's a network problem?
3) It's a network problem?
4) may be a client (rhel) problem?

 ps.: Many clients stil working pretty well, just some clients show
the slow behavior.

 Thanks a lot for your time!

 Leal.

-- 
pOSix rules
