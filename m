Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3-phx2.redhat.com ([209.132.183.24]:53577 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbaAPQyK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jan 2014 11:54:10 -0500
Date: Thu, 16 Jan 2014 11:54:07 -0500 (EST)
From: Bob Peterson <rpeterso@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Miklos Szeredi <mszeredi@suse.cz>
Message-ID: <1875464309.3327883.1389891247171.JavaMail.root@redhat.com>
In-Reply-To: <20140116164411.GD16829@fieldses.org>
References: <20140115151749.GF23999@fieldses.org> <20140116161015.GC16829@fieldses.org> <1389888942.2779.34.camel@menhir> <20140116164411.GD16829@fieldses.org>
Subject: Re: [PATCH] dcache: fix d_splice_alias handling of aliases
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message -----
| Something like this?
(snip)
| @@ -779,6 +782,11 @@ static struct dentry *__gfs2_lookup(struct inode *dir,
| struct dentry *dentry,
|  	}
|  
|  	d = d_splice_alias(inode, dentry);
| +	if (IS_ERR(d)) {
| +		iput(inode);
| +		gfs2_glock_dq_uninit(&gh);
| +		return ERR_PTR(error);

---------------------------------^
Shouldn't that be ERR_PTR(d)?

Bob Peterson
Red Hat File Systems
