Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55935 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab1EEWC6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2011 18:02:58 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p45Lpe7l021293
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 15:51:40 -0600
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p45M3cqe056660
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 16:03:39 -0600
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p45M2Ta6022158
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 16:02:29 -0600
Date: Thu, 5 May 2011 17:02:28 -0500
From: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, ecryptfs-devel@lists.launchpad.net
Subject: Re: [PATCH] NFS: Allow NULL nameidata in d_revalidate and create
Message-ID: <20110505220227.GG12250@boyd.l.tihix.com>
References: <1304609741-12541-1-git-send-email-tyhicks@linux.vnet.ibm.com>
 <20110505155728.GB12250@boyd.l.tihix.com>
 <1304613413.20441.2.camel@lade.trondhjem.org>
 <20110505185839.GF12250@boyd.l.tihix.com>
 <1304622496.20441.23.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1304622496.20441.23.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu May 05, 2011 at 03:08:16PM -0400, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Thu, 2011-05-05 at 13:58 -0500, Tyler Hicks wrote:
> > On Thu May 05, 2011 at 12:36:53PM -0400, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > > On Thu, 2011-05-05 at 10:57 -0500, Tyler Hicks wrote:
> > > > On Thu May 05, 2011 at 10:35:41AM -0500, Tyler Hicks <tyhicks@linux.vnet.ibm.com> wrote:
> > > > > To add support for eCryptfs mounts on top of NFS client mounts, the NFS
> > > > > client must properly handle NULL nameidata pointers in its d_revalidate
> > > > > functions.
> > > > > 
> > > > > NFS clients should also handle NULL nameidata in its create functions,
> > > > > although this is not currently required for eCryptfs support.
> > > > > 
> > > > > Signed-off-by: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
> > > > > ---
> > > > 
> > > > We (eCryptfs) are in the process of switching mailing lists, so I copied
> > > > both the old (launchpad.net) and the new (vger.kernel.org), but it
> > > > doesn't look like the vger.kernel.org list is accepting mail yet. Sorry
> > > > about that, I should have tested it first. Feel free to drop it from
> > > > any replies.
> > > > 
> > > > I should also mention that if/when this patch is merged, eCryptfs will
> > > > have basic support of mounting on top of NFSv3 client mounts. I say
> > > > basic because I'm sure there are some bugs, I'm not yet confident that
> > > > the required cache flushes are there in the eCryptfs layer to have NFSv3
> > > > cache consistency, and we have some trouble with silly rename.
> > > > 
> > > > All files unlinked through eCryptfs get silly renamed in the NFS client
> > > > because of the extra reference eCryptfs holds on the NFS dentry.
> > > > 
> > > > This also seems to come into play when unlinking the last file in a
> > > > directory and then immediately removing the directory. nfs_rmdir() will
> > > > sometimes return -EBUSY.
> > > > 
> > > > BTW, I think these are all issues that should be handled in the eCryptfs
> > > > layer, but I wanted to provide an update on the status of eCryptfs on
> > > > top of NFS.
> > > 
> > > Why would we want to 'support' ecryptfs in this manner? Can't you set up
> > > a proper nameidata with appropriate open intents?
> > 
> > Sorry, that was bad wording in my commit message. NFS would not be
> > "supporting" eCryptfs. eCryptfs supports the filesystem that it is
> > mounted on top of. We keep any quirks from the stacking scheme in
> > fs/ecryptfs/ and don't expect filesystems to do anything special for
> > eCryptfs.
> > 
> > In this case, I believe it is a bug for NFS to oops on NULL nameidata in
> > d_revalidate. It was introduced by 34286d66 and 657e94b6 and has been
> > fixed in most other filesystems (9177ada9, 8ce84eeb, 4714e637, 53fe9241,
> > 529c5f95, 0eb980e3).
> > 
> > I saw two potential oopses in the NFS create functions and patched
> > those, too. However, in the case of create, eCryptfs does pass a proper
> > nameidata to vfs_create().
> 
> Does it do so to d_revalidate() when opening a file?

I don't believe so.

> 
> > > 
> > > This patch might allow you to look up files on NFS, but without open
> > > intents, you certainly won't be able to open them, nor will you be able
> > > to create them (as you seem to believe).
> > 
> > I'm not sure why open and create would not work. My testing shows that
> > with this patch applied, I can compile the kernel in an eCryptfs mount
> > mounted on top of an NFSv3 client, run fsx-linux, etc.
> 
> Please try testing with NFSv4, which requires intents in both lookup()
> and d_revalidate() when opening a file.

I acknowledge that eCryptfs won't work on top of NFSv4 in its current
form. The lookup, create, and open paths in eCryptfs will need some
rewriting, as you've mentioned.

This patch simply allows eCryptfs to be mounted on top of NFSv3, which
is the first step in allowing client-side file encryption. This is an
eCryptfs feature that is asked for quite often and I hope you'll
reconsider merging the patch until I can make the changes needed to
support NFSv4.

Tyler

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
