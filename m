From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: 64bit inodes and IA32 apps over NFS
Date: Fri, 13 Aug 2010 16:47:03 +0200
Message-ID: <20100813144703.GP20901@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:41560 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754468Ab0HMOqm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Aug 2010 10:46:42 -0400
Received: from anubis.ics.muni.cz (anubis.ics.muni.cz [147.251.3.109])
	(authenticated user=xhejtman-/qMqeO8aiZrEwhJ7BL7w9Q@public.gmane.org bits=0)
	by minas.ics.muni.cz (8.13.8/8.13.8/SuSE Linux 0.8) with ESMTP id o7DEkc9u026362
	(version=TLSv1/SSLv3 cipher=AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 13 Aug 2010 16:46:39 +0200
Received: from xhejtman by anubis.ics.muni.cz with local (Exim 4.72)
	(envelope-from <xhejtman-muXYU8BwpB4yxAW3W1Oy7esEoJ4y9sgM@public.gmane.org>)
	id 1OjvXD-0000Mx-GA
	for linux-nfs@vger.kernel.org; Fri, 13 Aug 2010 16:47:03 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

is there any workaround for NFSv4 when exporting XFS with 64bit inodes?

IA32 apps receives:
getdents(3, 0xb7571008, 1000)           =3D -1 EOVERFLOW (Value too lar=
ge for defined data type)

when compiling on x86_64, I got not error.

=46rom the XFS man page:
By default, with 32bit inodes, XFS places inodes only in the first 1TB =
of
a disk. If you have a disk with 100TB, all inodes will be stuck in the =
first
TB. This can lead to strange things like "disk full" when you still hav=
e
plenty space free, but there's no more place in the first TB to create =
a new
inode. Also, performance sucks.

To come around this, use the inode64 mount options for filesystems >1TB=
=2E
Inodes will then be placed in the location where their data is, minimiz=
ing
disk seeks.

Beware that some old programs might have problems reading 64bit inodes,
especially over NFS.


So, is there any workaround in NFS for IA32 apps?

--=20
Luk=E1=B9 Hejtm=E1nek
