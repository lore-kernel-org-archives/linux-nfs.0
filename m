Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:23287 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab1ACQBk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jan 2011 11:01:40 -0500
Subject: Re: [patch -next] lockd: double unlock in next_host_state()
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110102202042.GN1886@bicker>
Date: Mon, 3 Jan 2011 10:59:36 -0500
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Message-Id: <001458D4-F513-4959-9BE7-476F8542D009@oracle.com>
References: <20110102202042.GN1886@bicker>
To: Dan Carpenter <error27@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 2, 2011, at 3:20 PM, Dan Carpenter wrote:

> We unlock again after we goto out.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> index c106d6a..5f1bcb2 100644
> --- a/fs/lockd/host.c
> +++ b/fs/lockd/host.c
> @@ -532,7 +532,6 @@ static struct nlm_host *next_host_state(struct hlist_head *cache,
> 			host->h_state++;
> 
> 			nlm_get_host(host);
> -			mutex_unlock(&nlm_host_mutex);
> 			goto out;
> 		}
> 	}

Would it also make sense to replace the "goto out;" with a "break;" ?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




