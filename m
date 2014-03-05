Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:49497 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbaCEGtt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Mar 2014 01:49:49 -0500
Date: Wed, 5 Mar 2014 06:49:46 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/8] NFS: prepare for RCU-walk support but pushing tests
 later in code.
Message-ID: <20140305064946.GY18016@ZenIV.linux.org.uk>
References: <20140305025813.27421.23871.stgit@notabene.brown>
 <20140305030028.27421.92032.stgit@notabene.brown>
 <20140305053441.GX18016@ZenIV.linux.org.uk>
 <20140305165933.09ca9d84@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140305165933.09ca9d84@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 05, 2014 at 04:59:33PM +1100, NeilBrown wrote:
> > 	b) having already become negative.
> 
> I didn't think dentries ever became negative.  When a file is deleted the old
> positive dentry is unlinked and a new negative dentry is created in it's
> place.
> Or has that changed since last I looked?

It has never been true.  See what d_delete() is doing.  If there was only
one reference to dentry, it *does* become negative.

> If they can become negative, then I could
>    dir = ACCESS_ONCE(parent->d_inode);
>    if (!dir)
>         return -ECHILD;
> 
> Do you think that would be safe?

Depends on what you do with it afterwards...
