Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36328 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732379AbeGLVaD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Jul 2018 17:30:03 -0400
Date: Thu, 12 Jul 2018 17:18:41 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v9 5/9] NFSD introduce async copy feature
Message-ID: <20180712211840.GA31361@parsley.fieldses.org>
References: <20180709192638.44799-1-kolga@netapp.com>
 <20180709192638.44799-6-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180709192638.44799-6-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 09, 2018 at 03:26:34PM -0400, Olga Kornievskaia wrote:
> +static __be32 nfsd4_init_copy_res(struct nfsd4_copy *copy, bool sync)
> +{
> +	memcpy(&copy->cp_res.cb_stateid, &copy->cp_dst_stateid,
> +		sizeof(copy->cp_dst_stateid));
> +	copy->cp_res.wr_stable_how = NFS_UNSTABLE;
> +	copy->cp_synchronous = sync;
> +	gen_boot_verifier(&copy->cp_res.wr_verifier, copy->cp_clp->net);
> +
> +	return nfs_ok;

Just make this return void if you're not using the error return.

--b.
