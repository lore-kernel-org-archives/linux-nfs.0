Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8769 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755364Ab1EEQgz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2011 12:36:55 -0400
Subject: Re: [PATCH] NFS: Allow NULL nameidata in d_revalidate and create
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
Cc: linux-nfs@vger.kernel.org, ecryptfs-devel@lists.launchpad.net
In-Reply-To: <20110505155728.GB12250@boyd.l.tihix.com>
References: <1304609741-12541-1-git-send-email-tyhicks@linux.vnet.ibm.com>
	 <20110505155728.GB12250@boyd.l.tihix.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 05 May 2011 12:36:53 -0400
Message-ID: <1304613413.20441.2.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-05-05 at 10:57 -0500, Tyler Hicks wrote:
> On Thu May 05, 2011 at 10:35:41AM -0500, Tyler Hicks <tyhicks@linux.vnet.ibm.com> wrote:
> > To add support for eCryptfs mounts on top of NFS client mounts, the NFS
> > client must properly handle NULL nameidata pointers in its d_revalidate
> > functions.
> > 
> > NFS clients should also handle NULL nameidata in its create functions,
> > although this is not currently required for eCryptfs support.
> > 
> > Signed-off-by: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
> > ---
> 
> We (eCryptfs) are in the process of switching mailing lists, so I copied
> both the old (launchpad.net) and the new (vger.kernel.org), but it
> doesn't look like the vger.kernel.org list is accepting mail yet. Sorry
> about that, I should have tested it first. Feel free to drop it from
> any replies.
> 
> I should also mention that if/when this patch is merged, eCryptfs will
> have basic support of mounting on top of NFSv3 client mounts. I say
> basic because I'm sure there are some bugs, I'm not yet confident that
> the required cache flushes are there in the eCryptfs layer to have NFSv3
> cache consistency, and we have some trouble with silly rename.
> 
> All files unlinked through eCryptfs get silly renamed in the NFS client
> because of the extra reference eCryptfs holds on the NFS dentry.
> 
> This also seems to come into play when unlinking the last file in a
> directory and then immediately removing the directory. nfs_rmdir() will
> sometimes return -EBUSY.
> 
> BTW, I think these are all issues that should be handled in the eCryptfs
> layer, but I wanted to provide an update on the status of eCryptfs on
> top of NFS.

Why would we want to 'support' ecryptfs in this manner? Can't you set up
a proper nameidata with appropriate open intents?

This patch might allow you to look up files on NFS, but without open
intents, you certainly won't be able to open them, nor will you be able
to create them (as you seem to believe).

NACKed...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

