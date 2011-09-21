Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from flagman.cpositive.ru ([188.40.232.74]:48954 "EHLO
	flagman.cpositive.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751007Ab1IUEoI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Sep 2011 00:44:08 -0400
Received: from base.home.my (unknown [95.189.24.151])
	by flagman.cpositive.ru (Postfix) with ESMTPA id 7CAF427D0BB7
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 04:35:49 +0000 (UTC)
Received: from st01.localnet (st01.home.my [192.168.8.1])
	by base.home.my (Postfix) with ESMTP id 65FDE66
	for <linux-nfs@vger.kernel.org>; Wed, 21 Sep 2011 13:35:48 +0900 (IRKT)
From: Stanislav Posonsky <psk@cpositive.ru>
To: linux-nfs@vger.kernel.org
Subject: Error: state manager failed on NFSv4 server base with error 10018
Date: Wed, 21 Sep 2011 13:34:34 +0900
Content-Type: Text/Plain;
  charset="utf-8"
Message-Id: <201109211334.34497.psk@cpositive.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

	After upgrade kernel at server from 2.6.38 to 2.6.39 series and higher, 
I was forced to drop to NFSv3. With NFSv4 I get (when I trying to read any 
file) hundreds message at client:

	Error: state manager failed on NFSv4 server base with error 10018

	Now I have at server and cient:

	linux kernel 	3.0.4
	nfs-utils		1.2.3
	nfs4-acl-tools	0.3.3

	File /etc/exports:

/opt                        192.168.8.0/24(fsid=0,rw,subtree_check)

==================================================
	With version 3
==================================================

root|st01# mount -t nfs -o nfsvers=3 base:/opt /net
root|st01# mount | grep nfs
rpc_pipefs on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
base:/opt on /net type nfs (rw,nfsvers=3,addr=192.168.8.254)

	In other console:

stas@st01$ ls -l /net/a*
-rw-r--r-- 1 root root 35 Сен 21 11:23 /net/a_file.txt
stas@st01$ cat /net/a_file.txt 
This is a test file on NFS share.

stas@st01$	

	Works fine.

==================================================
	With version 4
==================================================

root|st01# umount /net
root|st01# mount -t nfs base:/ /net
root|st01# mount | grep nfs
rpc_pipefs on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw)
base:/ on /net type nfs (rw,vers=4,addr=192.168.8.254,clientaddr=192.168.8.1)

	In other console:

stas@st01$ ls -l /net/a*
-rw-r--r-- 1 root root 35 Сен 21 11:23 /net/a_file.txt
stas@st01$ cat /net/a_file.txt

	And the process hangs... Then (Ctl+C):

^C
stas@st01$ dmesg
Error: state manager failed on NFSv4 server base with error 10018
Error: state manager failed on NFSv4 server base with error 10018
...

Could you help me solve this problem, please?
-- 
  With best regards, Stanislav 
