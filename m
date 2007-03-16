From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/4] nfs-utils : fix some bugs of umount.nfs
Date: Fri, 16 Mar 2007 14:04:29 +1100
Message-ID: <17914.2365.273536.108233@notabene.brown>
References: <1173098587.4825.9.camel@LINE> <45F79A30.5080408@nanjing-fnst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Wei Yongjun <yjwei@nanjing-fnst.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HS2k9-0000xi-0U
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 20:04:37 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HS2kA-0000zz-Sq
	for nfs@lists.sourceforge.net; Thu, 15 Mar 2007 20:04:39 -0700
In-Reply-To: message from Wei Yongjun on Wednesday March 14
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

On Wednesday March 14, yjwei@nanjing-fnst.com wrote:
> This patch series has 4 patches to fix some bugs of umount.nfs command.
> 
> [PATCH 1/4]  Use correct UMNT version to do umount
> [PATCH 2/4]  Fix nfs4 umount to not used umount procedure
> [PATCH 3/4]  Use correct UMNT protocol to do umount
> [PATCH 4/4]  Rename add_mtab2() to del_mtab()
> 
> These is also some work to do with umount.nfs, such as following:
> 
> 1. getmntdirbackward() does not free the memory it malloc, which may 
> cause memory leak, also can be found it my patch.

I don't think this is a big problem.  mount.nfs is a short-lived
program so a little memory not being freed is not a concern.

> 
> 2. If file /proc/mounts it wasn't found and we can not found mount entry 
> in /etc/mtab(it has been removed from this file), umount will fail with 
> message "umount: %s: not found"

In this case there is nothing for mount.nfs to do anyway as we don't
know which server to talk to.  Presumably /bin/mount will try to call
unmount on the path, which should be enough.

> 
> 3. If the server is down, we can not umount an nfs filesystem, I can 
> make a patch, but I don't know if the server is down, do we have 
> permission to umount?  Can  umount  fail from  remote  server because 
> of  permission problem?

We certainly should be able to unmount an NFS filesystem if the server
is down.  unmount is mostly a local operation.  We don't need any
permission from the server to do it.
As a courtesy, we tell the NFS server that we have unmounted it so it
can update it's 'rmtab' file.  But there isn't even any guarantee of
that if the client simply crashes.

So if it doesn't currently work when the server is down, and you can
make a patch to fix that, I would really appreciate it.

Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
