From: Igor Chudov <ichudov@gmail.com>
Subject: NFS _write_ Performance became horrible overnight
Date: Mon, 12 Jul 2010 10:37:48 -0500
Message-ID: <AANLkTinaHi1bZYRwI-jXiv_xPhQyvTUGmzBrfP-JRYs3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50627 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab0GLPiK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jul 2010 11:38:10 -0400
Received: by wwi17 with SMTP id 17so146858wwi.1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2010 08:38:09 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I would like to apologize in advance if, for any reason, my question
is inappropriate for this mailing list. Please let meknow if that is
the case.

This seems to be a very odd problem that I have isolated to NFS.

I have two NFS servers. Server A and server B. They serve unrelated
shares.

Server A is actually two servers using DRBD to stay in sync.

I also have a number of NFS clients.

Both servers worked great up to about last night.

Somehow, NFS writes became extremely slow over Server A, for all
clients, but not for Server B.

I have no idea, yet, what changed, but wanted to ask here if anyone
ever had a similar problem (NFS performance going to shit overnight).

Some data points:

1) From any client, reading files over NFS is fast
2) From any client, writing to NFS on Server A is VERY SLOW
3) From any client, writing to Samba shares on Server A is fast.
4) From any client, writing to NFS on Server B is fast.
5) When logged on to Server A, copying a file from local A filesystem
to itself is fast.

IOW, everything is fast, EXCEPT for NFS writes to server A.

Any ideas what might cause this sudden deterioration of Server A?

Thank you!!!!!!!!!!!

i
