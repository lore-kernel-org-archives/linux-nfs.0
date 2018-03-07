Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42154 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933412AbeCGVng (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Mar 2018 16:43:36 -0500
Date: Wed, 7 Mar 2018 16:43:36 -0500
To: Olga Kornievskaia <kolga@netapp.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v7 06/10] NFSD return nfs4_stid in
 nfs4_preprocess_stateid_op
Message-ID: <20180307214336.GD28844@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com>
 <20180220164229.65404-7-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180220164229.65404-7-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 20, 2018 at 11:42:25AM -0500, Olga Kornievskaia wrote:
> @@ -5143,8 +5144,11 @@ static __be32 nfsd4_validate_stateid(struct nfs4_client *cl, stateid_t *stateid)
>  	if (!status && filpp)
>  		status = nfs4_check_file(rqstp, fhp, s, filpp, tmp_file, flags);
>  out:
> -	if (s)
> +	if (s) {
> +		if (!status && cstid)
> +			*cstid = s;
>  		nfs4_put_stid(s);

Are you sure that's right?  Normally you wouldn't drop a reference on
something you're returning.

--b.
