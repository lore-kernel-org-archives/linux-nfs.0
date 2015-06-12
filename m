Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtprelay0033.hostedemail.com ([216.40.44.33]:59960 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752890AbbFLRSB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 13:18:01 -0400
Message-ID: <1434129477.2972.38.camel@perches.com>
Subject: Re: [PATCH 1/1 linux-next] pnfs/flexfiles: use swap() in
 ff_layout_sort_mirrors()
From: Joe Perches <joe@perches.com>
To: Fabian Frederick <fabf@skynet.be>
Cc: linux-kernel@vger.kernel.org, Julia Lawall <Julia.Lawall@lip6.fr>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Date: Fri, 12 Jun 2015 10:17:57 -0700
In-Reply-To: <1434128330-10253-1-git-send-email-fabf@skynet.be>
References: <1434128330-10253-1-git-send-email-fabf@skynet.be>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2015-06-12 at 18:58 +0200, Fabian Frederick wrote:
> Use kernel.h macro definition.

A lot of these conversions seem to be for bubble sorts.
Maybe it'd be useful to add a generic one somewhere.

> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
[]
> @@ -182,17 +182,14 @@ static void _ff_layout_free_lseg(struct nfs4_ff_layout_segment *fls)
>  
>  static void ff_layout_sort_mirrors(struct nfs4_ff_layout_segment *fls)
>  {
> -	struct nfs4_ff_layout_mirror *tmp;
>  	int i, j;
>  
>  	for (i = 0; i < fls->mirror_array_cnt - 1; i++) {
>  		for (j = i + 1; j < fls->mirror_array_cnt; j++)
>  			if (fls->mirror_array[i]->efficiency <
> -			    fls->mirror_array[j]->efficiency) {
> -				tmp = fls->mirror_array[i];
> -				fls->mirror_array[i] = fls->mirror_array[j];
> -				fls->mirror_array[j] = tmp;
> -			}
> +			    fls->mirror_array[j]->efficiency)
> +				swap(fls->mirror_array[i],
> +				     fls->mirror_array[j]);
>  	}
>  }
>  



