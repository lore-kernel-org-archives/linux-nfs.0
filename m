From: "James Pearson" <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Subject: Problems with Mac clients mounting a Linux server behind a firewall
Date: Fri, 19 Dec 2008 22:52:22 +0000
Message-ID: <a92ebfd90812191452l4b10362av5e9c8876335c32bc@mail.gmail.com>
Reply-To: james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:38940 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754473AbYLSWwY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Dec 2008 17:52:24 -0500
Received: by ewy10 with SMTP id 10so1313330ewy.13
        for <linux-nfs@vger.kernel.org>; Fri, 19 Dec 2008 14:52:22 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm not absolutely sure if this is an NFS server issue, but I have an
Linux NFS server running CentOS4 that sits behind a firewall - about
once a week rpciod ends up using 99% CPU and the machine needs to be
rebooted

When it gets into this state, running 'netstat -u -a' shows thousands
of entries like:

udp        0      0 *:35071                     *:*
udp        0      0 *:34815                     *:*
udp        0      0 *:34559                     *:*
udp        0      0 *:34303                     *:*
udp        0      0 *:34047                     *:*
udp        0      0 *:33791                     *:*
udp        0      0 *:33535                     *:*
udp        0      0 *:33279                     *:*
udp        0      0 *:33151                     *:*
udp        0      0 *:32895                     *:*

and tcpdump shows lots of udp connection attempts to port 111 on
various Macs that are or have mounted the server (via an automounter).
The connections don't get through as they are blocked by the firewall.
None of these blocked connections are to Linux clients - it's just Mac
clients

Is there anything that NFS server-wise that could be cause the server
to attempt to contact clients in this way?

Thanks

James Pearson
