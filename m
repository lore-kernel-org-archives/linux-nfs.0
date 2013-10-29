Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46242 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755066Ab3J2NGu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 09:06:50 -0400
Date: Tue, 29 Oct 2013 09:06:49 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131029130649.GA29606@fieldses.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131028214030.GO31322@fieldses.org>
 <526FAF30.3060502@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <526FAF30.3060502@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 08:50:56AM -0400, Anna Schumaker wrote:
> On Mon 28 Oct 2013 05:40:30 PM EDT, J. Bruce Fields wrote:
> > On Mon, Oct 28, 2013 at 10:57:25AM -0400, Anna Schumaker wrote:
> >> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> >> index 419572f..3210c6f 100644
> >> --- a/fs/nfsd/nfs4proc.c
> >> +++ b/fs/nfsd/nfs4proc.c
> >> @@ -1028,6 +1028,42 @@ nfsd4_write(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> >>  	return status;
> >>  }
> >>
> >> +static __be32
> >> +nfsd4_write_plus_hole(struct file *file, struct nfsd4_write_plus *writeplus,
> >> +		      struct net *net)
> >> +{
> >> +	__be32 status;
> >> +
> >> +	status = nfsd4_vfs_fallocate(file, writeplus->wp_allocated,
> >> +				writeplus->wp_offset, writeplus->wp_length);
> >> +	if (status == nfs_ok) {
> >> +		writeplus->wp_res.wr_stid = NULL;
> >> +		writeplus->wp_res.wr_bytes_written = writeplus->wp_length;
> >> +		writeplus->wp_res.wr_stable_how = NFS_FILE_SYNC;
> >
> > Do we need to sync?
> 
> I did the sync in nfsd4_vfs_fallocate (below), but I can move it if 
> that would make more sense.

What I meant was--why are we doing a sync at all, instead of returning
NFS_UNSTABLE and making the client commit?

Honest question, I haven't thought about which is best.

--b.
