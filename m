Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:59110 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422784AbbFEPCR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Jun 2015 11:02:17 -0400
Date: Fri, 5 Jun 2015 16:02:13 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 5/5] nfsd: allows user un-mounting filesystem where nfsd
 exports base on
Message-ID: <20150605150213.GV7232@ZenIV.linux.org.uk>
References: <5561E7E4.50604@gmail.com>
 <5561E9FA.4050808@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5561E9FA.4050808@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 24, 2015 at 11:10:50PM +0800, Kinglong Mee wrote:
> --- a/fs/nfsd/export.c
> +++ b/fs/nfsd/export.c
> @@ -43,9 +43,9 @@ static void expkey_put(struct kref *ref)
>  
>  	if (test_bit(CACHE_VALID, &key->h.flags) &&
>  	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
> -		path_put(&key->ek_path);
> +		path_put_unpin(&key->ek_path, &key->ek_pin);
>  	auth_domain_put(key->ek_client);
> -	kfree(key);
> +	kfree_rcu(key, rcu_head);
>  }

That looks wrong.  OK, so you want umount() to proceed; fine, no problem
with that.  However, what happens if the final mntput() hits while you
are just approaching that path_put_unpin()?  ->kill() will be triggered,
and it would bloody better
	a) make sure that expkey_put() is called for that key if it hadn't
already been done and
	b) do not return until such expkey_put() completes.  Including the
ones that might have been already entered by the time we'd got to ->kill().

Am I missing something subtle here?
