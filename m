From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH v2 11/35] pnfsd: get device list/info
Date: Thu, 10 Dec 2009 14:04:02 -0500
Message-ID: <20091210190402.GA12559@fieldses.org>
References: <4B1CCA52.8020900@panasas.com> <1260178330-15032-1-git-send-email-bhalevy@panasas.com> <20091210173003.GL9484@fieldses.org> <4B214394.4030808@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	linux-fsdevel@vger.kernel.org, Marc Eshel <eshel@almaden.ibm.com>,
	Andy Adamson <andros@umich.edu>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>,
	Dean Hildebrand <seattleplus@gmail.com>,
	Dean Hildebrand <dhildeb@us.ibm.com>,
	Fred Isaman <iisaman@citi.umich.edu>,
	Mike Sager <sager@netapp.com>, Andy Adamson <andros@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51972 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761553AbZLJTDp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Dec 2009 14:03:45 -0500
In-Reply-To: <4B214394.4030808@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 10, 2009 at 08:53:08PM +0200, Benny Halevy wrote:
> On Dec. 10, 2009, 19:30 +0200, " J. Bruce Fields" <bfields@citi.umich.edu> wrote:
> > On Mon, Dec 07, 2009 at 11:32:10AM +0200, Benny Halevy wrote:
> >> +static __be32
> >> +nfsd4_getdevinfo(struct svc_rqst *rqstp,
> >> +		struct nfsd4_compound_state *cstate,
> >> +		struct nfsd4_pnfs_getdevinfo *gdp)
> >> +{
> >> +	struct super_block *sb;
> >> +	struct svc_export *exp = NULL;
> >> +	u32 fsidv = gdp->gd_devid.fsid;
> >> +	int status;
> >> +
> >> +	dprintk("%s: layout_type %u dev_id %llx:%llx maxcnt %u\n",
> >> +	       __func__, gdp->gd_layout_type, gdp->gd_devid.fsid,
> >> +	       gdp->gd_devid.devid, gdp->gd_maxcount);
> >> +
> >> +	status = nfserr_inval;
> >> +	exp = rqst_exp_find(rqstp, FSID_NUM, &fsidv);
> > 
> > As I said before, this seems to require an fsid= option on every pnfs
> > export.  We shouldn't need that.
> 
> If there a better way to get to the sb given the fsid?
> Since we don't have a current_fh for getdeviceinfo the alternative
> might be to map the deviceids to sb's in the generic layer.

Does the deviceid even need to persist over reboots?  If not, then just
an index into an in-memory table might be good enough.  If it does need
to persist, then I guess we should look at the filehandle-decoding code
for inspiration.

--b.
