From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH 0/4] nfs-utils : fix some bugs of umount.nfs
Date: Wed, 14 Mar 2007 14:46:08 +0800
Message-ID: <45F79A30.5080408@nanjing-fnst.com>
References: <1173098587.4825.9.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HRNKK-0002JR-EF
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 23:51:12 -0700
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HRNKI-0008PQ-93
	for nfs@lists.sourceforge.net; Tue, 13 Mar 2007 23:51:14 -0700
In-Reply-To: <1173098587.4825.9.camel@LINE>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This patch series has 4 patches to fix some bugs of umount.nfs command.

[PATCH 1/4]  Use correct UMNT version to do umount
[PATCH 2/4]  Fix nfs4 umount to not used umount procedure
[PATCH 3/4]  Use correct UMNT protocol to do umount
[PATCH 4/4]  Rename add_mtab2() to del_mtab()

These is also some work to do with umount.nfs, such as following:

1. getmntdirbackward() does not free the memory it malloc, which may 
cause memory leak, also can be found it my patch.

2. If file /proc/mounts it wasn't found and we can not found mount entry 
in /etc/mtab(it has been removed from this file), umount will fail with 
message "umount: %s: not found"

3. If the server is down, we can not umount an nfs filesystem, I can 
make a patch, but I don't know if the server is down, do we have 
permission to umount?  Can  umount  fail from  remote  server because 
of  permission problem?


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
