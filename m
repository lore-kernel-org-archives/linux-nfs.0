From: Olaf Kirch <okir@suse.de>
Subject: Re: Mount version older than kernel: 4 vs. 6
Date: Wed, 4 Aug 2004 15:04:19 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040804130419.GI4471@suse.de>
References: <4110DB81.4020103@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="SkvwRMAIpAhPCcCJ"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsLRP-0005EW-My
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 06:04:23 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BsLRO-0004Cn-QA
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 06:04:23 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 431939CB141
	for <nfs@lists.sourceforge.net>; Wed,  4 Aug 2004 15:04:19 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <4110DB81.4020103@bio.ifi.lmu.de>
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


--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Aug 04, 2004 at 02:50:09PM +0200, Frank Steiner wrote:
> Just a stupid question: why does the nfsmount.h from the kernel source
> define NFS_MOUNT_VERSION 6? Shouldn't this number match the latest nfs
> version, i.e., 4? I've never heard of nfs v6 yet :-)
> Or is the meaning of NFS_MOUNT_VERSION different?

That's the version of the NFS kernel mount struct, and is
absolutely unrelated to the NFS version (except that both
grow monotonically over time).

> Would it be safe to patch nfsmount.h and set the number to 4 for my
> own kernel to get rid of this warning, or could that break sth. else?
> It just fills my logs and I want to get rid of it...

Our kernel has a patch to silence that warning for versions < 3.
But I wouldn't mind if it was nixed entirely.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--SkvwRMAIpAhPCcCJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=nfs-mount-warning

Bug #36841: Disable ``mount version is older than kernel'' warning:
The kernel for SL 9.1 will support a higher mount version than the
mount binary.

Bug #37689: Some people still saw kernel messages complaining about
the mount version. It seems this happens when the first mount attempt
using kernel mount version 4 fails for some reason (for instance if
the server doesn't support NFSv3) mount falls back to mount version 3.
So we should really warn about versions < 3 only.    --okir

Index: linux-2.6.4/fs/nfs/inode.c
===================================================================
--- linux-2.6.4.orig/fs/nfs/inode.c
+++ linux-2.6.4/fs/nfs/inode.c
@@ -1389,8 +1389,9 @@ static struct super_block *nfs_get_sb(st
 		memset(root->data+root->size, 0, sizeof(root->data)-root->size);
 
 	if (data->version != NFS_MOUNT_VERSION) {
-		printk("nfs warning: mount version %s than kernel\n",
-			data->version < NFS_MOUNT_VERSION ? "older" : "newer");
+		if (data->version < 3)
+			printk("nfs warning: mount version %d is older "
+			       "than 3\n", data->version);
 		if (data->version < 2)
 			data->namlen = 0;
 		if (data->version < 3)

--SkvwRMAIpAhPCcCJ--


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
