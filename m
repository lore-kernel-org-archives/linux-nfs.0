Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59474 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753158AbdIFVhE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Sep 2017 17:37:04 -0400
Date: Wed, 6 Sep 2017 17:37:03 -0400
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com,
        bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC v3 25/42] NFSD add COPY_NOTIFY operation
Message-ID: <20170906213703.GE24694@fieldses.org>
References: <20170711164416.1982-1-kolga@netapp.com>
 <20170711164416.1982-26-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170711164416.1982-26-kolga@netapp.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 11, 2017 at 12:43:59PM -0400, Olga Kornievskaia wrote:
> +struct nfsd4_copy_notify {
> +	/* request */
> +	stateid_t		cpn_src_stateid;
> +	struct nl4_server	cpn_dst;
> +
> +	/* response */
> +	/* Note: cpn_src_stateid is used for cnr_stateid */

That might be worth a little more explanation.

--b.

> +	u64			cpn_sec;
> +	u32			cpn_nsec;
> +	struct nl4_servers	cpn_src;
> +};
> +
