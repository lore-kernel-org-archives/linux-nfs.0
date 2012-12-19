Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:63726 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751100Ab2LSWGO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2012 17:06:14 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: =?utf-7?B?UGF3ZStBVUktIFNpa29yYQ==?= <pawel.sikora@agmk.net>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: Re: [3.6.11] NFS: Cache request denied due to non-unique superblock
 keys.
Date: Wed, 19 Dec 2012 22:06:12 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91196C0B0@SACEXCMBX04-PRD.hq.netapp.com>
References: <6078496.RFsWrNWv86@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91196AB48@SACEXCMBX04-PRD.hq.netapp.com>
	 <2073442.2DDQICUc2y@localhost>
In-Reply-To: <2073442.2DDQICUc2y@localhost>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2012-12-19 at 22:16 +-0100, Pawe+AUI- Sikora wrote:
+AD4- On Wednesday 19 of December 2012 19:35:50 Myklebust, Trond wrote:
+AD4- +AD4- On Wed, 2012-12-19 at 19:58 +--0100, Pawe+-AUI- Sikora wrote:
+AD4- +AD4- +-AD4- Hi,
+AD4- +AD4- +-AD4- 
+AD4- +AD4- +-AD4- i'm testing the 3.6.11 kernel on some small internal nfs network (1 server +-ADw--+-AD4- 2 clients)
+AD4- +AD4- +-AD4- and observing such info in dmesg on the client side. could you put some light on this dmesg entry?
+AD4- +AD4- +-AD4- is it a bug or misconfiguration? i can provide more information about nfs configuration
+AD4- +AD4- +-AD4- if necessary but denying caching doesn't look nicely.
+AD4- +AD4- +-AD4- 
+AD4- +AD4- +-AD4- i'm using following nfs related packages:
+AD4- +AD4- +-AD4- 
+AD4- +AD4- +-AD4- autofs-5.0.5-1.x86+-AF8-64
+AD4- +AD4- +-AD4- libnfsidmap-0.25-4.x86+-AF8-64
+AD4- +AD4- +-AD4- nfs-utils-1.2.7-1.x86+-AF8-64
+AD4- +AD4- +-AD4- nfs-utils-clients-1.2.7-1.x86+-AF8-64
+AD4- +AD4- +-AD4- nfs-utils-common-1.2.7-1.x86+-AF8-64
+AD4- +AD4- +-AD4- 
+AD4- +AD4- +-AD4- BR,
+AD4- +AD4- +-AD4- Pawe+-AUI-.
+AD4- +AD4- 
+AD4- +AD4- It's hard to guess when you don't tell us anything about what you are
+AD4- +AD4- doing to trigger this message, but it sounds as if you are trying to use
+AD4- +AD4- the cachefs mount options incorrectly.
+AD4- 
+AD4- on the server side there're following exports:
+AD4- 
+AD4- +ACM- exportfs -v
+AD4- /home/atest/farm-local
+AD4-                 +ADw-world+AD4-(rw,async,wdelay,nohide,crossmnt,no+AF8-root+AF8-squash,no+AF8-subtree+AF8-check,insecure+AF8-locks)
+AD4- /home/atest/farm
+AD4-                 +ADw-world+AD4-(rw,async,wdelay,nohide,crossmnt,no+AF8-root+AF8-squash,no+AF8-subtree+AF8-check,insecure+AF8-locks)
+AD4- /home/users     +ADw-world+AD4-(rw,no+AF8-root+AF8-squash,no+AF8-subtree+AF8-check,insecure+AF8-locks)
+AD4- 
+AD4- in the exported /home/atest/+ACo- there're crossmounted/binded directories:
+AD4- 
+AD4- +ACM- fstab
+AD4- /home/atest/farm-local/results  /home/atest/farm/results        none bind
+AD4- /home/services/ftp              /var/lib/ftp                    none bind
+AD4- /home/services/ftp              /home/atest/farm-local/ftp      none bind
+AD4- 
+AD4- +ACM- df -h
+AD4- Filesystem                   Size  Used Avail Use+ACU- Mounted on
+AD4- rootfs                       7.6G  4.5G  2.7G  63+ACU- /
+AD4- /dev/md0                     7.6G  4.5G  2.7G  63+ACU- /
+AD4- run                           32G  264K   32G   1+ACU- /run
+AD4- devtmpfs                      32G     0   32G   0+ACU- /dev
+AD4- /dev/md1                     7.2T  794G  6.4T  11+ACU- /home
+AD4- none                          32G     0   32G   0+ACU- /dev/shm
+AD4- /dev/md1                     7.2T  794G  6.4T  11+ACU- /home/atest/farm/results
+AD4- /dev/md1                     7.2T  794G  6.4T  11+ACU- /var/lib/ftp
+AD4- /dev/md1                     7.2T  794G  6.4T  11+ACU- /home/atest/farm-local/ftp
+AD4- 
+AD4- 
+AD4- on the client side there's only a simple autofs configuration:
+AD4- 
+AD4- +ACM- cat /etc/autofs/auto.server
+AD4- farm           -rw,soft,rsize+AD0-32768,wsize+AD0-32768,intr,vers+AD0-4,async,bg,noatime,retry+AD0-30,retrans+AD0-10        192.168.2.100:/home/atest/farm-local
+AD4- home           -rw,soft,vers+AD0-4        192.168.2.100:/home/users
+AD4- 

OK. If you are not specifying '-ofsc', then that warning is 100+ACU-
confusing. How about the following patch?

8+ADw----------------------------------------------------------------
>From e8ed657ba5edc8c9339e00ab2fd235ab1dd94cd5 Mon Sep 17 00:00:00 2001
From: Trond Myklebust +ADw-Trond.Myklebust+AEA-netapp.com+AD4-
Date: Wed, 19 Dec 2012 16:56:28 -0500
Subject: +AFs-PATCH+AF0- NFS: Kill fscache warnings when mounting without -ofsc
MIME-Version: 1.0
Content-Type: text/plain+ADs- charset+AD0-UTF-8
Content-Transfer-Encoding: 8bit

The fscache code will currently bleat a +ACI-non-unique superblock keys+ACI-
warning even if the user is mounting without the 'fsc' option.
There should be no reason to even initialise the superblock cache cookie
unless we're planning on using fscache for something, so ensure that
we check for the NFS+AF8-OPTION+AF8-FSCACHE flag before calling into the
fscache code.

Reported-by: Pawe+AUI- Sikora +ADw-pawel.sikora+AEA-agmk.net+AD4-
Signed-off-by: Trond Myklebust +ADw-Trond.Myklebust+AEA-netapp.com+AD4-
Cc: David Howells +ADw-dhowells+AEA-redhat.com+AD4-
---
 fs/nfs/super.c +AHw- 19 +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-----
 1 file changed, 15 insertions(+-), 4 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index aa5315b..c25cadf8 100644
--- a/fs/nfs/super.c
+-+-+- b/fs/nfs/super.c
+AEAAQA- -2375,19 +-2375,30 +AEAAQA- static void nfs+AF8-get+AF8-cache+AF8-cookie(struct super+AF8-block +ACo-sb,
 				 struct nfs+AF8-parsed+AF8-mount+AF8-data +ACo-parsed,
 				 struct nfs+AF8-clone+AF8-mount +ACo-cloned)
 +AHs-
+-	struct nfs+AF8-server +ACo-nfss +AD0- NFS+AF8-SB(sb)+ADs-
 	char +ACo-uniq +AD0- NULL+ADs-
 	int ulen +AD0- 0+ADs-
 
-	if (parsed +ACYAJg- parsed-+AD4-fscache+AF8-uniq) +AHs-
-		uniq +AD0- parsed-+AD4-fscache+AF8-uniq+ADs-
-		ulen +AD0- strlen(parsed-+AD4-fscache+AF8-uniq)+ADs-
+-	nfss-+AD4-fscache+AF8-key +AD0- NULL+ADs-
+-	nfss-+AD4-fscache +AD0- NULL+ADs-
+-
+-	if (parsed) +AHs-
+-		if (+ACE-(parsed-+AD4-options +ACY- NFS+AF8-OPTION+AF8-FSCACHE))
+-			return+ADs-
+-		if (parsed-+AD4-fscache+AF8-uniq) +AHs-
+-			uniq +AD0- parsed-+AD4-fscache+AF8-uniq+ADs-
+-			ulen +AD0- strlen(parsed-+AD4-fscache+AF8-uniq)+ADs-
+-		+AH0-
 	+AH0- else if (cloned) +AHs-
 		struct nfs+AF8-server +ACo-mnt+AF8-s +AD0- NFS+AF8-SB(cloned-+AD4-sb)+ADs-
+-		if (+ACE-(mnt+AF8-s-+AD4-options +ACY- NFS+AF8-OPTION+AF8-FSCACHE))
+-			return+ADs-
 		if (mnt+AF8-s-+AD4-fscache+AF8-key) +AHs-
 			uniq +AD0- mnt+AF8-s-+AD4-fscache+AF8-key-+AD4-key.uniquifier+ADs-
 			ulen +AD0- mnt+AF8-s-+AD4-fscache+AF8-key-+AD4-key.uniq+AF8-len+ADs-
 		+AH0AOw-
-	+AH0-
+-	+AH0- else
+-		return+ADs-
 
 	nfs+AF8-fscache+AF8-get+AF8-super+AF8-cookie(sb, uniq, ulen)+ADs-
 +AH0-
-- 
1.7.11.7


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
