Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56276 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751208AbdEKHi7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 May 2017 03:38:59 -0400
Date: Thu, 11 May 2017 08:38:57 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 14/14] Add commands to create or update a superblock
Message-ID: <20170511073857.GL390@ZenIV.linux.org.uk>
References: <149443309780.2378.6532276992468576087.stgit@warthog.procyon.org.uk>
 <149443323117.2378.6029610622093309047.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <149443323117.2378.6029610622093309047.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 10, 2017 at 05:20:31PM +0100, David Howells wrote:
  
> @@ -64,8 +70,8 @@ struct sb_config_operations {
>  	int (*parse_option)(struct sb_config *sc, char *p);
>  	int (*monolithic_mount_data)(struct sb_config *sc, void *data);
>  	int (*validate)(struct sb_config *sc);
> -	struct dentry *(*mount)(struct sb_config *sc);
> -	int (*fill_super)(struct super_block *s, struct sb_config *sc);
> +	int (*create_super)(struct sb_config *sc);

Hell, NO.

The primary effect of that thing is *NOT* to create a superblock.  It
might be a side effect, and quite often it will happen, but the
real goal here is a mountable tree.  Which might or might not reside
on a new superblock.  And which might very well involve no object
creation whatsoever.

This name is actively misleading and the same goes for its relatives
(vfs_create_super(), etc.).  It's "give me a tree to mount", not
"create something or other".
