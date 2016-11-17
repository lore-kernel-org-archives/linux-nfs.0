Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:56636 "EHLO
        mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750776AbcKQUmq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2016 15:42:46 -0500
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
        by mailsrv.ikr.uni-stuttgart.de (Postfix) with ESMTP id A7F3C19C0002
        for <linux-nfs@vger.kernel.org>; Thu, 17 Nov 2016 21:32:47 +0100 (CET)
Received: from ikr.uni-stuttgart.de (inode21-c [10.11.18.11])
        by netsrv1.ikr.uni-stuttgart.de (Postfix) with SMTP id 84BB71A20608
        for <linux-nfs@vger.kernel.org>; Thu, 17 Nov 2016 21:32:47 +0100 (CET)
From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: NFS Server prevents access to files on different scenarios (lock problem?)
Date: Thu, 17 Nov 2016 21:32:47 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Message-Id: <201611172132.47523.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

we use Linux NFS clients with a Linux NFS server in an configuration
where NFS mounts are done on client boot _and_ on user login in a
session; umounts are done on users logout from the session.

We see occasionally several different problems which all may have
the same root cause:

- When a client accesses a file which was accessed before
  from the same client in a previous session the server
  prevents access to the file until a timeout happens.

  The timeout has a duration of about 1-3 minutes.
  In this case the "blocked" file can not even be deleted
  on the server.

  --> What causes this timeout? I found nothing in the
      server code which has such a timeout How can I debug what
      the server is waiting for or why he is blocking access
      to the file?

- Sometimes client processes hang in the middle of a session
  on some file. After a timeout the file is accessible again.
  The timeout can take 1 upto several minutes. The file is
  also blocked on the server, it cannot be accessed.

I think all theses problemes are caused by something like
dangling locks or another invalid state on the server.

The clients show no network error like dropped packets
or something like this.

--> How can I debug such hangs?

We use Linux NFS server and client from vanilla kernel 4.4.31
with sec=sys.

Can anyone help? Does "a bell ring"?

Thank you and best regards

-Ulrich

-- 
| Ulrich Gemkow
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
