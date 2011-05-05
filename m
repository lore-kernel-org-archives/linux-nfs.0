Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:36163 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752898Ab1EETAU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 May 2011 15:00:20 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p45Ia6Go001344
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 14:36:06 -0400
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p45J0CiZ1032418
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 15:00:13 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p45J3hCv022815
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 13:03:44 -0600
Date: Thu, 5 May 2011 13:58:40 -0500
From: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, ecryptfs-devel@lists.launchpad.net
Subject: Re: [PATCH] NFS: Allow NULL nameidata in d_revalidate and create
Message-ID: <20110505185839.GF12250@boyd.l.tihix.com>
References: <1304609741-12541-1-git-send-email-tyhicks@linux.vnet.ibm.com>
 <20110505155728.GB12250@boyd.l.tihix.com>
 <1304613413.20441.2.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1304613413.20441.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu May 05, 2011 at 12:36:53PM -0400, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Thu, 2011-05-05 at 10:57 -0500, Tyler Hicks wrote:
> > On Thu May 05, 2011 at 10:35:41AM -0500, Tyler Hicks <tyhicks@linux.vnet.ibm.com> wrote:
> > > To add support for eCryptfs mounts on top of NFS client mounts, the NFS
> > > client must properly handle NULL nameidata pointers in its d_revalidate
> > > functions.
> > > 
> > > NFS clients should also handle NULL nameidata in its create functions,
> > > although this is not currently required for eCryptfs support.
> > > 
> > > Signed-off-by: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
> > > ---
> > 
> > We (eCryptfs) are in the process of switching mailing lists, so I copied
> > both the old (launchpad.net) and the new (vger.kernel.org), but it
> > doesn't look like the vger.kernel.org list is accepting mail yet. Sorry
> > about that, I should have tested it first. Feel free to drop it from
> > any replies.
> > 
> > I should also mention that if/when this patch is merged, eCryptfs will
> > have basic support of mounting on top of NFSv3 client mounts. I say
> > basic because I'm sure there are some bugs, I'm not yet confident that
> > the required cache flushes are there in the eCryptfs layer to have NFSv3
> > cache consistency, and we have some trouble with silly rename.
> > 
> > All files unlinked through eCryptfs get silly renamed in the NFS client
> > because of the extra reference eCryptfs holds on the NFS dentry.
> > 
> > This also seems to come into play when unlinking the last file in a
> > directory and then immediately removing the directory. nfs_rmdir() will
> > sometimes return -EBUSY.
> > 
> > BTW, I think these are all issues that should be handled in the eCryptfs
> > layer, but I wanted to provide an update on the status of eCryptfs on
> > top of NFS.
> 
> Why would we want to 'support' ecryptfs in this manner? Can't you set up
> a proper nameidata with appropriate open intents?

Sorry, that was bad wording in my commit message. NFS would not be
"supporting" eCryptfs. eCryptfs supports the filesystem that it is
mounted on top of. We keep any quirks from the stacking scheme in
fs/ecryptfs/ and don't expect filesystems to do anything special for
eCryptfs.

In this case, I believe it is a bug for NFS to oops on NULL nameidata in
d_revalidate. It was introduced by 34286d66 and 657e94b6 and has been
fixed in most other filesystems (9177ada9, 8ce84eeb, 4714e637, 53fe9241,
529c5f95, 0eb980e3).

I saw two potential oopses in the NFS create functions and patched
those, too. However, in the case of create, eCryptfs does pass a proper
nameidata to vfs_create().

> 
> This patch might allow you to look up files on NFS, but without open
> intents, you certainly won't be able to open them, nor will you be able
> to create them (as you seem to believe).

I'm not sure why open and create would not work. My testing shows that
with this patch applied, I can compile the kernel in an eCryptfs mount
mounted on top of an NFSv3 client, run fsx-linux, etc.

Tyler

> 
> NACKed...
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
