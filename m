Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56270 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961Ab2KLRvC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Nov 2012 12:51:02 -0500
Date: Mon, 12 Nov 2012 12:50:54 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "David P. Quigley" <selinux@davequigley.com>
Cc: David Quigley <dpquigl@davequigley.com>, trond.myklebust@netapp.com,
        sds@tycho.nsa.gov, linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org,
        "Matthew N. Dodd" <Matthew.Dodd@sparta.com>,
        Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>,
        Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>,
        Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Subject: Re: [PATCH 07/13] NFSv4: Introduce new label structure
Message-ID: <20121112175054.GP30713@fieldses.org>
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com>
 <1352700947-3915-8-git-send-email-dpquigl@davequigley.com>
 <20121112151314.GG30713@fieldses.org>
 <50A116A8.20105@davequigley.com>
 <20121112160523.GJ30713@fieldses.org>
 <50A12979.3040902@davequigley.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50A12979.3040902@davequigley.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 12, 2012 at 11:53:13AM -0500, David P. Quigley wrote:
> On 11/12/2012 11:05 AM, J. Bruce Fields wrote:
> >On Mon, Nov 12, 2012 at 10:32:56AM -0500, David P. Quigley wrote:
> >>On 11/12/2012 10:13 AM, J. Bruce Fields wrote:
> >>>On Mon, Nov 12, 2012 at 01:15:41AM -0500, David Quigley wrote:
> >>>>From: David Quigley<dpquigl@davequigley.com>
> >>>>
> >>>>In order to mimic the way that NFSv4 ACLs are implemented we have created a
> >>>>structure to be used to pass label data up and down the call chain. This patch
> >>>>adds the new structure and new members to the required NFSv4 call structures.
> >>>>
> >>>>Signed-off-by: Matthew N. Dodd<Matthew.Dodd@sparta.com>
> >>>>Signed-off-by: Miguel Rodel Felipe<Rodel_FM@dsi.a-star.edu.sg>
> >>>>Signed-off-by: Phua Eu Gene<PHUA_Eu_Gene@dsi.a-star.edu.sg>
> >>>>Signed-off-by: Khin Mi Mi Aung<Mi_Mi_AUNG@dsi.a-star.edu.sg>
> >>>>Signed-off-by: David Quigley<dpquigl@davequigley.com>
> >>>>---
> >>>>  fs/nfs/inode.c          | 40 ++++++++++++++++++++++++++++++++++++++++
> >>>>  fs/nfsd/xdr4.h          |  3 +++
> >>>>  include/linux/nfs4.h    |  8 ++++++++
> >>>>  include/linux/nfs_fs.h  | 14 ++++++++++++++
> >>>>  include/linux/nfs_xdr.h | 20 ++++++++++++++++++++
> >>>>  5 files changed, 85 insertions(+)
> >>>>
> >>>>diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> >>>>index 5c7325c..0963ad9 100644
> >>>>--- a/fs/nfs/inode.c
> >>>>+++ b/fs/nfs/inode.c
> >>>>@@ -246,6 +246,46 @@ nfs_init_locked(struct inode *inode, void *opaque)
> >>>>  	return 0;
> >>>>  }
> >>>>
> >>>>+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
> >>>>+struct nfs4_label *nfs4_label_alloc(gfp_t flags)
> >>>>+{
> >>>>+	struct nfs4_label *label = NULL;
> >>>>+
> >>>>+	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);
> >>>NFS4_MAXLABELLEN is 4096, but we usually try to avoid allocating more
> >>>than that in a single allocation.
> >>Should we make this smaller? I figured a page would be a good upper bound.
> >If we could make it small enough so that the above fits in 4096 bytes
> >that would be easier.
> >
> >(What does the protocol say?  On a quick glance it doesn't seem to
> >impose a limit.)
> 
> The spec doesn't limit the size of a label but we thought that a
> page would be good. We can make it 4095 to ensure that it will
> always be in a page incase a null terminator is added. I believe
> someone mentioned this in the past I'm not sure why it didn't make
> its way in. We initially had something much larger but Trond chimed
> in and said that if its larger than a page something is wrong so we
> lowered it.

Note that sizeof(struct nfs4_label) in there too.  So maybe subtract the
maximum possible size of that thing, then round down to something nice?

--b.
