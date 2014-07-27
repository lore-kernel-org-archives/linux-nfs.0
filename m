Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58772 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaG0Nqx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:46:53 -0400
Date: Sun, 27 Jul 2014 06:46:52 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 11/40] nfsd: ensure atomicity in nfsd4_free_stateid and
 nfsd4_validate_stateid
Message-ID: <20140727134652.GA28068@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-12-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-12-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  	case NFS4_OPEN_STID:
>  	case NFS4_LOCK_STID:
>  		ret = check_stateid_generation(stateid, &s->sc_stateid, 1);
>  		if (ret)
> -			goto out;
> -		if (s->sc_type == NFS4_LOCK_STID)
> -			ret = nfsd4_free_lock_stateid(openlockstateid(s));
> -		else
> +			break;
> +		if (s->sc_type != NFS4_LOCK_STID) {
>  			ret = nfserr_locks_held;
> -		break;
> +			break;
> +		}
> +		spin_unlock(&cl->cl_lock);
> +		ret = nfsd4_free_lock_stateid(openlockstateid(s));
> +		goto out;

Might be worth to split the open and lock stateid cases here.

Otherwise looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

