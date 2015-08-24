Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:59224 "EHLO
	mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754264AbbHXNCs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2015 09:02:48 -0400
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by mailsrv.ikr.uni-stuttgart.de (Postfix) with ESMTP id D296B60204
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 14:52:57 +0200 (CEST)
Received: from ikr.uni-stuttgart.de (pc041 [10.21.21.41])
	by netsrv1.ikr.uni-stuttgart.de (Postfix) with SMTP id B95B660203
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2015 14:52:57 +0200 (CEST)
From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 mount fails on Sun Solaris 10 after reboot of client
Date: Mon, 24 Aug 2015 14:52:55 +0200
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201508241452.57718.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

we have a weired problem with Linux NFSv4.0 Server (Vanilla
Kernel 4.1.6) and a Sun Solaris 10 client (all patches applied):

When mounting a share on the Solaris client and then rebooting
the client without unmounting the share first, after the reboot
every attempt to mount the share again gives an I/O error on
the client and the mount fails.

After a long time (serveral hours) the v4 mount suddenly works
again.

Mounting a share with vers=2 works always even in times when
the v4 mount fails.

So it seems the Linux NFSv4 server holds a state for the client
which prevents the re-mounting of the share and gives the
I/O-error on the client.

We use NFSv4 without idmapd.

Is there any tip how to debug or solve this?

Thank you and best regards

-Ulrich

-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart, Germany
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------
