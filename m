From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: kernel BUG at fs/nfs/namespace.c:108!
Date: Mon, 04 Aug 2008 11:27:42 -0700
Message-ID: <1217874462.28654.6.camel@dyn9047022153>
References: <72924.9082.qm@web39205.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Shahar Klein <shaharklein@yahoo.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:48449 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752730AbYHDSOK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Aug 2008 14:14:10 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m74IGRUm022359
	for <linux-nfs@vger.kernel.org>; Mon, 4 Aug 2008 14:16:27 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m74IDk1D232390
	for <linux-nfs@vger.kernel.org>; Mon, 4 Aug 2008 14:13:46 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m74IDkEX016532
	for <linux-nfs@vger.kernel.org>; Mon, 4 Aug 2008 14:13:46 -0400
In-Reply-To: <72924.9082.qm-OZWcxxNrvPKvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 2008-08-03 at 03:07 -0700, Shahar Klein wrote:
> Hi  All
> 
> I came across this panic due to bad server and I am wondering
> why should an nfs client panic when stumbling upon an IS_ROOT dentry
> in the point where it tries to cross mount. I mean: should an 'Innocent' client
> 'pay' for bad server behavior?
> 
> Is it unsafe to just clear the path and return error?

What kernel are you running? There was some discussion of this BUG_ON
back in January/February (with this same subject). It was coming up with
referrals and security negotiation and Neil Brown posted some patches
that resolved the issue for me.

I did also find a problem with it from a bad kernel, and tried to return
an error (here is my discussion from back then):

One thing I discovered, even immediately issuing umount will cause the
BUG. The root dentry for the mount is basically useless.

It turns out this was due to a bad bug in nfs-utils in
utils/mountd/cache.c (I am working on some stuff in that file). It
basically caused user space to write a bad export into the kernel. It
does seem that it's not a good idea for the client to crash in this case
though.

Perhaps that BUG_ON at fs/nfs/namespace.c:108 should be changed. I tried
returning an error instead of BUGing, but that didn't seem to work.

While trying to debug the client, I did try this:

--- ./fs/nfs/getroot.c.orig     2008-01-30 16:57:25.000000000 -0800
+++ ./fs/nfs/getroot.c  2008-01-30 12:18:28.000000000 -0800
@@ -270,6 +270,13 @@ struct dentry *nfs4_get_root(struct supe
                return ERR_PTR(error);
        }

+       //FSFTEMP try this out
+       if (!nfs_fsid_equal(&server->fsid, &fattr.fsid)) {
+               printk(KERN_WARNING "FSFTEMP trying to fix fsid=%lld:%lld to fsid=%lld:%lld\n",
+                       server->fsid.major, server->fsid.minor,
+                       fattr.fsid.major, fattr.fsid.minor);
+               memcpy(&server->fsid, &fattr.fsid, sizeof(server->fsid));
+       }
        inode = nfs_fhget(sb, mntfh, &fattr);
        if (IS_ERR(inode)) {
                dprintk("nfs_get_root: get root inode failed\n");


It keeps the client from hitting the BUG_ON at least. Between the messed
up server and this fix, doing the ls shown above shows the contents of
server:/ (which is on the file system with the fsid that ends up being
changed to).

While debugging, I did a network trace. The client does a LOOKUP home
followed by a GETATTR. This reports the fsid 8:3 that is correct for
server:/home. Later, the client does another getattr (just before the
patch in nfs4_get_root()) which reports fsid 8:1.

I don't think this is a real fix, and fortunately, with a correct
nfs-utils on the server, the client doesn't hit this, but perhaps it
bears some investigation to find a proper fix.

And another comment:

Hmm, a quick look to refresh my memory reminds me why I didn't get
further with this earlier, the problem is this particular situation is
detectable in getroot. If it is not dealt with then, the result is
somehow the root dentry of the mount never gets hooked into the tree,
but it does get identified as a crossmount (or referral), which it
should not be at this point (the crossmounting has already occurred to
get this far in mounting. Then later, when the mount is accessed, it
tries to follow the crossmount but nfs_follow_mountpoint barfs on the
detached dentry (which appears as root to IS_ROOT). 

So the question may be how to differentiate this case from a legitimate
crossmount. 

Certainly looks like a good puzzle to be solved :-) 

I ended up bailing on on further investigation since the problem was a
result of a server bug that never made it out into the wild.

Frank


