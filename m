Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linuxhacker.ru ([217.76.32.60]:49372 "EHLO fiona.linuxhacker.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751077AbcFCE6U convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Jun 2016 00:58:20 -0400
Subject: Re: NFS/d_splice_alias breakage
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
From: Oleg Drokin <green@linuxhacker.ru>
In-Reply-To: <20160603042648.GN14480@ZenIV.linux.org.uk>
Date: Fri, 3 Jun 2016 00:58:10 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>,
        "<linux-fsdevel@vger.kernel.org>" <linux-fsdevel@vger.kernel.org>
Message-Id: <51139F5D-8CC8-4448-B3AB-5EF1B67E2D6C@linuxhacker.ru>
References: <CF78E59B-F311-437B-9D1C-1F3FF6C22126@linuxhacker.ru> <20160603033750.GL14480@ZenIV.linux.org.uk> <0C971585-6BFC-4665-832B-9B262F733BFC@linuxhacker.ru> <20160603042648.GN14480@ZenIV.linux.org.uk>
To: Al Viro <viro@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 3, 2016, at 12:26 AM, Al Viro wrote:

> On Thu, Jun 02, 2016 at 11:43:59PM -0400, Oleg Drokin wrote:
> 
>>> Which of the call sites had that been and how does one reproduce that fun?
>>> If you feel that posting a reproducer in the open is a bad idea, just send
>>> it off-list...
>> 
>> This is fs/nfs/dir.c::nfs_lookup() right after no_entry label.
> 
> Bloody hell...  Was that sucker hashed on the entry into nfs_lookup()?
> If we get that with call as a method, we are really fucked.
> 
> <greps>
> 
> Ho-hum...  One of the goto no_open; in nfs_atomic_open()?  That would
> mean a stale negative dentry in dcache that has escaped revalidation...
> Wait a minute, didn't nfs ->d_revalidate() skip everything in some
> cases, leaving it to ->atomic_open()?
> 
> Looks like the right thing to do would be to do d_drop() at no_open:,
> just before we call nfs_lookup().  If not earlier, actually...  How
> about the following?

This one cures the insta-crash I was having, and I see no other ill-effects so far.

> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index aaf7bd0..6e3a6f4 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1536,9 +1536,9 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
> 		err = PTR_ERR(inode);
> 		trace_nfs_atomic_open_exit(dir, ctx, open_flags, err);
> 		put_nfs_open_context(ctx);
> +		d_drop(dentry);
> 		switch (err) {
> 		case -ENOENT:
> -			d_drop(dentry);
> 			d_add(dentry, NULL);
> 			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
> 			break;

