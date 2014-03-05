Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:49327 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbaCEFeo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 00:34:44 -0500
Date: Wed, 5 Mar 2014 05:34:41 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/8] NFS: prepare for RCU-walk support but pushing tests
 later in code.
Message-ID: <20140305053441.GX18016@ZenIV.linux.org.uk>
References: <20140305025813.27421.23871.stgit@notabene.brown>
 <20140305030028.27421.92032.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140305030028.27421.92032.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 05, 2014 at 02:00:28PM +1100, NeilBrown wrote:
> -	parent = dget_parent(dentry);
> +		parent = rcu_dereference(dentry->d_parent);
> +	else
> +		parent = dget_parent(dentry);
>  	dir = parent->d_inode;
>  	nfs_inc_stats(dir, NFSIOS_DENTRYREVALIDATE);

... and in RCU mode there's nothing to stop parent from
	a) not being dentry->d_parent anymore
	b) having already become negative.

NAK.
