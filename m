Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:44914 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754010Ab0EJL0X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 May 2010 07:26:23 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id o4ABQM9q024603
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 10 May 2010 13:26:22 +0200
Received: from mail1.itwm.fhg.de ([131.246.191.78]:56569)
	by itwm2.itwm.fhg.de with esmtps (TLSv1:DES-CBC3-SHA:168)
	(/C=DE/ST=Rheinland-Pfalz/L=Kaiserslautern/O=Fraunhofer ITWM/OU=SLG/CN=mail1.itwm.fhg.de)(verified=1)
	 (Exim 4.66 #1)
	id 1OBR7u-0004eU-7t
	for linux-nfs@vger.kernel.org; Mon, 10 May 2010 13:26:22 +0200
Message-ID: <4BE7ED5D.90801@itwm.fraunhofer.de>
Date: Mon, 10 May 2010 13:26:21 +0200
From: Martin Vogt <martin.vogt@itwm.fraunhofer.de>
To: linux-nfs@vger.kernel.org
Subject: permission denied with >= ~2.6.25
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hello list,

recently I updated my client to a new vendor kernel(SLES11), but the
problem is the same if I use a 2.6.33.3 as a client.

If I'm doing svn checkouts in an endless loop,
or running make -j X builds sometimes it happens
that I get a "Permision denied" error.

If I strace it, for svn, the following sequence appears:


5262  rename("Kernel.ERWQPsWCA5/.svn/tmp/entries",
"Kernel.ERWQPsWCA5/.svn/entries") = 0
5262  lstat("Kernel.ERWQPsWCA5/.svn/entries", {st_mode=S_IFREG|0666,
st_size=205, ...}) = 0
5262  chmod("Kernel.ERWQPsWCA5/.svn/entries", 0444) = 0
5262  open("Kernel.ERWQPsWCA5/.svn/format.tmp", O_RDWR|O_CREAT|O_EXCL,
0666) = 3
5262  write(3, "9\n", 2)                = 2
5262  close(3)                          = 0


5262  rename("Kernel.ERWQPsWCA5/.svn/format.tmp",
"Kernel.ERWQPsWCA5/.svn/format") = 0
5262  lstat("Kernel.ERWQPsWCA5/.svn/format", 0x7fff79949350) = -1 EACCES
(Permission denied)
^^^^^^^^^^^^ Here

5262  write(2, "svn: Can't change perms of file "..., 83) = 83
5262  lstat("Kernel.ERWQPsWCA5/.svn/log", 0x7fff79949650) = -1 ENOENT
(No such file or directory)
5262  unlink("Kernel.ERWQPsWCA5/.svn/lock") = 0


After a rename, the lstat call fails. I tried to isolate it,
but without any luck so far.

I dont have the problem if I go back to my vendor kernel <= 2.6.22.
I wonder if its more a NFS Server problem or a problem on the client
side so I tried writing a C programm to trigger this behaviour.
But without any success so far.

Maybe this problem is already known?


regards,

Martin
