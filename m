Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailsrv.ikr.uni-stuttgart.de ([129.69.170.2]:39321 "EHLO
	mailsrv.ikr.uni-stuttgart.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751023Ab3BDKU0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 05:20:26 -0500
Received: from netsrv1.ikr.uni-stuttgart.de (netsrv1-c [10.11.12.12])
	by mailsrv.ikr.uni-stuttgart.de (Postfix) with ESMTP id B7A48600FF
	for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2013 11:12:03 +0100 (CET)
Received: from ikr.uni-stuttgart.de (pc001 [10.21.21.1])
	by netsrv1.ikr.uni-stuttgart.de (Postfix) with SMTP id A21D6600FE
	for <linux-nfs@vger.kernel.org>; Mon,  4 Feb 2013 11:12:03 +0100 (CET)
From: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
To: linux-nfs@vger.kernel.org
Subject: Linux 3.7 + Sun solaris 10: Problems when reading dir from application
Date: Mon, 4 Feb 2013 11:12:03 +0100
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Message-Id: <201302041112.03587.ulrich.gemkow@ikr.uni-stuttgart.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

we upgraded our fileserver from Linux 3.2 to linux 3.7.6 and now have
problems when accessing our nfs-mounted user homes from some sun-
applications (i.e. Adobe Framemaker):

In the applications file open box, no files are displayed. When entering
the filename by path, the file can be opened. So it seems some kind of
dir enumeration which is used by the sun applications is broken.

Other programs on the sun like ls work as before and show all files.

We are using NFSv3 (and cannot switch to v4). Our sun is a very old
machine running Sun Solaris 10.

Is there any help?

Thanks and best regards

Ulrich

-- 
|-----------------------------------------------------------------------
| Ulrich Gemkow
| University of Stuttgart
| Institute of Communication Networks and Computer Engineering (IKR)
|-----------------------------------------------------------------------
