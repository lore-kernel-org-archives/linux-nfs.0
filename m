From: Andre Majorel <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>
Subject: atimes not updated over NFS
Date: Wed, 9 Jan 2008 11:13:13 +0100
Message-ID: <20080109101313.GG9212@aym.net2.nerim.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-dmz-233-wednesday.dmz.nerim.net ([195.5.254.233]:56782
	"EHLO kellthuzad.dmz.nerim.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751026AbYAIKey (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jan 2008 05:34:54 -0500
Received: from mallaury.nerim.net (smtp-103-wednesday.noc.nerim.net [62.4.17.103])
	by kellthuzad.dmz.nerim.net (Postfix) with ESMTP id E301527530
	for <linux-nfs@vger.kernel.org>; Wed,  9 Jan 2008 11:15:12 +0100 (CET)
Received: from atc5.vermine.org (aym.net2.nerim.net [213.41.173.68])
	by mallaury.nerim.net (Postfix) with ESMTP id 020A64F4AB
	for <linux-nfs@vger.kernel.org>; Wed,  9 Jan 2008 11:13:08 +0100 (CET)
Received: from aym by atc5.vermine.org with local (Exim 4.63)
	(envelope-from <aym-xunil-Bi/FLWfhfolQFI55V6+gNQ@public.gmane.org>)
	id 1JCXvt-0001LZ-WA
	for linux-nfs@vger.kernel.org; Wed, 09 Jan 2008 11:13:14 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After upgrading an NFS server from kernel 2.6.12 to 2.6.23, the
atime of files is not updated any more when clients read them :

  client$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
  -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz
  client$ md5sum /nfsmnt/zz
  d41d8cd98f00b204e9800998ecf8427e  /nfsmnt/zz
  client$ date +%Y-%m-%d_%H:%M:%S
  2007-12-21_15:00:28
  client$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
  -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz

Reading the file locally, i.e. on the NFS server, does update the
atime :

  server$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
  -rw-r--r-- 1 xxx xxx 0 2007-12-21_14:58:11 /nfsmnt/zz
  serveur$ md5sum /nfsmnt/zz
  d41d8cd98f00b204e9800998ecf8427e  /nfsmnt/zz
  serveur$ date +%Y-%m-%d_%H:%M:%S
  2007-12-21_15:04:00
  serveur$ ll -u --time-style +%Y-%m-%d_%H:%M:%S /nfsmnt/zz
  -rw-r--r-- 1 xxx xxx 0 2007-12-21_15:03:57 /nfsmnt/zz

/nfsmnt is mounted with options :
- server : rw,noexec,nosuid,nodev,nodiratime
- client : rw,user=3Droot,nosuid,nodev,nodiratime,intr,rsize=3D8192,wsi=
ze=3D8192

Any ideas ?

--=20
Andr=E9 Majorel <URL:http://www.teaser.fr/~amajorel/>
Do not use this account for regular correspondence.
See the URL above for contact information.
