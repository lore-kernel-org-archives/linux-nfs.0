From: Jos van Wezel <jvw@iwr.fzk.de>
Subject: permission bits for group not honoured on directory creation
Date: Thu, 2 Sep 2004 22:08:54 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0409022203580.17829-100000@hikjos.fzk.de>
References: <E1C1GJx-00018A-2R@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C2xtN-0000LD-EA
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 13:09:09 -0700
Received: from fzkmail2.fzk.de ([141.52.27.52])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.34)
	id 1C2xtL-0000q8-Mp
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 13:09:09 -0700
Received: from hikjos.fzk.de (localhost [127.0.0.1])
	by hikjos.fzk.de (8.12.3/8.12.3/SuSE Linux 0.6) with ESMTP id i82K8sJm017839
	for <nfs@lists.sourceforge.net>; Thu, 2 Sep 2004 22:08:54 +0200
Received: from localhost (jvw@localhost)
	by hikjos.fzk.de (8.12.3/8.12.3/Submit) with ESMTP id i82K8sUB017836
	for <nfs@lists.sourceforge.net>; Thu, 2 Sep 2004 22:08:54 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <E1C1GJx-00018A-2R@sc8-sf-list2.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Dear all,

on an nfs v3 mounted file system (linux client and server):

# umask
0002
# mkdir d
# ls -ld d
drwxr-xr-x    2 root     root         8192 Sep  2  2004 d/
#

note the write bit is not set for group. The ability to create group
writable directories is important for our applications. A fix for
this, or a pointer to a solution would be greatly appreciated.

Jos




-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
