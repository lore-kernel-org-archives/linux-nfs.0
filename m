Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47312 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113AbaCGS4B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 13:56:01 -0500
Date: Fri, 7 Mar 2014 13:55:52 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "Yan, Zheng" <zheng.z.yan@intel.com>, David Howells <dhowells@redhat.com>,
        linux-fsdevel@vger.kernel.org,
        Viro Alexander <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        ceph-devel@vger.kernel.org, sage@inktank.com
Subject: Re: [PATCH][RESEND] vfs: Make __d_materialise_dentry() set the
 materialised dentry name correctly
Message-ID: <20140307185552.GA30256@fieldses.org>
References: <1394115376-17109-1-git-send-email-zheng.z.yan@intel.com>
 <6487FCC2-FB5C-4A32-94EF-5D3352A39781@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6487FCC2-FB5C-4A32-94EF-5D3352A39781@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 06, 2014 at 09:35:01AM -0500, Trond Myklebust wrote:
> 
> On Mar 6, 2014, at 9:16, Yan, Zheng <zheng.z.yan@intel.com> wrote:
> 
> > From: David Howells <dhowells@redhat.com>
> > 
> > Make __d_materialise_dentry() set the materialised dentry name correctly by
> > flipping the arguments to switch_names().
> > 
> > switch_names() is lazy: if both names are internal to their dentries, it'll
> > overwrite that of the first dentry with that of the second, and won't update
> > that of the second.
> > 
> > In the case of __d_materialise_dentry(), the second is an already extant
> > anonymous dentry that we want to insert into the tree in place of the dentry we
> > just looked up[*].  However, the dentry we just looked up carries the name we
> > actually want to use.
> > 
> > [*] This is used by NFS to join a mount of a subtree into a mount of a tree
> > nearer the root when the two meet, where both mounts share a superblock and
> > thus a set of dentries.
> > 
> > Signed-off-by: David Howells <dhowells@redhat.com>
> > ---
> > fs/dcache.c | 2 +-
> > 1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/dcache.c b/fs/dcache.c
> > index 265e0ce..ff779d4 100644
> > --- a/fs/dcache.c
> > +++ b/fs/dcache.c
> > @@ -2698,7 +2698,7 @@ static void __d_materialise_dentry(struct dentry *dentry, struct dentry *anon)
> > 
> > 	dparent = dentry->d_parent;
> > 
> > -	switch_names(dentry, anon);
> > +	switch_names(anon, dentry);
> > 	swap(dentry->d_name.hash, anon->d_name.hash);
> > 
> > 	dentry->d_parent = dentry;
> 
> Well spotted...
> 
> We ought to better document the fact that ’switch_names’ is asymmetrical. Perhaps change it to ‘update_target_name’, and then switch the argument names so that the ’target’ really is the thing that gets updated?

Probably not worth it if Miklos's RENAME_EXCHANGE operation is making it
symmetrical soon anyway?:

	http://mid.gmane.org/<1380643239-16060-4-git-send-email-miklos@szeredi.hu>

--b.
