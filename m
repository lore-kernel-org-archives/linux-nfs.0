Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e35.co.us.ibm.com ([32.97.110.153]:60396 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750948Ab3IJUS7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Sep 2013 16:18:59 -0400
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Tue, 10 Sep 2013 14:18:59 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 1D4143E40026
	for <linux-nfs@vger.kernel.org>; Tue, 10 Sep 2013 14:18:55 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8AKIdMN423130
	for <linux-nfs@vger.kernel.org>; Tue, 10 Sep 2013 14:18:40 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8AKLaXH005892
	for <linux-nfs@vger.kernel.org>; Tue, 10 Sep 2013 14:21:37 -0600
In-Reply-To: <20130628080643.037bc080@corrin.poochiereds.net>
References: <OF659496E7.43E03D23-ON87257B8E.004B852B-86257B8E.004BC3F6@us.ibm.com>	<1371568176.3868.5.camel@leira.trondhjem.org>
	<OF0A202F9C.685475CA-ON87257B8E.005E218B-86257B8E.006D757C@us.ibm.com>	<4FA345DA4F4AE44899BD2B03EEEC2FA93F422610@SACEXCMBX04-PRD.hq.netapp.com>
	<51CB3F08.9050005@RedHat.com>	<1372274707.36780.2.camel@leira.trondhjem.org>
	<OFFA688044.F059006D-ON87257B96.0074D508-86257B96.0075968C@us.ibm.com>	<1372294255.3192.4.camel@leira.trondhjem.org>
	<20130627004159.7852c43c@tlielax.poochiereds.net> <20130628080643.037bc080@corrin.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Al Viro <viro@ZenIV.linux.org.uk>
MIME-Version: 1.0
Subject: Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel
Message-ID: <OF53526F99.89324B1F-ON86257BE2.006EF3C4-86257BE2.006F919F@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Tue, 10 Sep 2013 15:18:58 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Reran the failing scenario today after applying kernel 3.12-1 with commits 
up to b1b3e136948a2bf4915326acb0d825d7d180753f from Trond.
    git://git.kernel.org/pub/scm/linux/kernel/git/mattst88/alpha
The scenario passed. I no longer see the Stale FH message on umount.

[root@reddy5 ~]# mount -overs=3,noac w42g:/hfs/home/chris /mnt
[root@reddy5 ~]# ls /mnt
mnt   mnt2  output   output2  reg
mnt1  mnt3  output1  output3
[root@reddy5 ~]# umount /mnt
[root@reddy5 ~]#   

Christopher Vogan
NFS Development & Test



From:   Jeff Layton <jlayton@redhat.com>
To:     Jeff Layton <jlayton@redhat.com>, 
Cc:     "Myklebust, Trond" <Trond.Myklebust@netapp.com>, Christopher T 
Vogan/San Jose/IBM@IBMUS, "linux-nfs@vger.kernel.org" 
<linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>, Al Viro 
<viro@ZenIV.linux.org.uk>, NeilBrown <neilb@suse.de>
Date:   06/28/2013 07:06 AM
Subject:        Re: NFSERR_STALE on umount  with 3.10.0.RC5 kernel



On Thu, 27 Jun 2013 00:41:59 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Thu, 27 Jun 2013 00:51:01 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
> 
> > On Wed, 2013-06-26 at 15:24 -0600, Christopher T Vogan wrote:
> > > This is a complete network trace between the client and server.
> > > 
> > > 
> > > So this issue only happens on Kernels 3.9.6 and newer.
> > > I did not have this problem with Kernel 3.8.13
> > > nfs-utils-1.2.3-36 (from Redhat) was used w/ all kernel versions.
> > 
> > Ah. I don't recall seeing that information before. In that case, I'm
> > guessing that the change in behaviour is likely to be commit
> > ecf3d1f1aa74da0d632b651a2e05a911f60e92c0 (vfs: kill FS_REVAL_DOT by
> > adding a d_weak_revalidate dentry op).
> > 
> > Jeff, any comment on what behaviour you expect on umount()
> > post-ecf3d1f1aa?
> > 
> 
> (cc'ing Al and Neil in case they have thoughts on this too...)
> 
> Well...not that :)
> 
> It seems like we have a bit of a perfect storm here -- noac + this
> strange server behavior wrt to UMNT calls. I can reproduce the client
> behavior (UMNT before a GETATTR), but of course my servers don't start
> rejecting calls when you send them a UMNT request.
> 
> First, I think I understand why you do *not* see this on earlier
> kernels. Those used d_revalidate to revalidate those dentries:
> 
> -------------[snip]-------------
>         if (!nfs_is_exclusive_create(dir, flags) && 
nfs_check_verifier(dir, dentry)) {
>                 if (nfs_lookup_verify_inode(inode, flags))
>                         goto out_zap_parent;
>                 goto out_valid;
>         }
> -------------[snip]-------------
> 
> So in this case, we're not doing an exclusive create and the verifier
> check returns true because IS_ROOT(dentry) is true.
> nfs_lookup_verify_inode returns false (none of the checks there pass),
> so we then treat this dentry as valid w/o doing any revalidation.
> 
> The new nfs_weak_revalidate function doesn't treat IS_ROOT() dentries in
> any special way. I did a quick test patch that makes
> nfs_weak_revalidate return 1 if IS_ROOT(dentry) is true. That seems to
> fix the problem. I'm not sure if it makes sense to always skip
> revalidating IS_ROOT dentries like that though. It seems a bit
> heavy-handed...
> 
> Like NeilB pointed out recently, umount() is a bit of a special case.
> We're not really interested in anything but the dentry here so not
> trying to revalidate the inode makes a lot of sense.
> 
> I wonder if it might make more sense to declare a new LOOKUP_NOREVAL
> flag or something and have umount() syscalls set it in the lookup? Then
> we could look for that and simply return 1 if it's set. Or maybe have
> the VFS skip calling d_weak_revalidate (and maybe d_revalidate)
> altogether if it's set.
> 
> On a related note, I think we ought to consider ripping out the UMNT
> code from the userland helper or maybe just retiring umount.nfs
> altogether. It's simply not possible for userland to handle that
> properly. The UMNT (if any) needs to be sent when we tear down the
> superblock, and only the kernel knows when that has happened.
> 

So, looking again at this. I think the right long-term solution is to
do what Neil suggested in this thread from a few months ago:

     "More fun with unmounting ESTALE directories."

Basically we ought to fix umount() to do its lookup without
revalidating the last step. We might also be able to get away without
revaliding any path components in the umount lookup, but that might be
more iffy if there are symlinks in the path...

In the near term, Christopher should be able to work around this
problem by simply getting rid of /sbin/umount.nfs. It'll mean that the
client doesn't send UMNT calls, but AIUI those are intended to be
advisory anyway.
-- 
Jeff Layton <jlayton@redhat.com>



