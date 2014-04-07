Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57285 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755187AbaDGUvc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Apr 2014 16:51:32 -0400
Date: Mon, 7 Apr 2014 16:51:21 -0400
To: Sage Weil <sage@inktank.com>
Cc: Viro Alexander <viro@zeniv.linux.org.uk>,
        "Yan, Zheng" <zheng.z.yan@intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        David Howells <dhowells@redhat.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org
Subject: Re: [PATCH][RESEND] vfs: Make __d_materialise_dentry() set the
 materialised dentry name correctly
Message-ID: <20140407205121.GA4426@fieldses.org>
References: <1394115376-17109-1-git-send-email-zheng.z.yan@intel.com>
 <6487FCC2-FB5C-4A32-94EF-5D3352A39781@primarydata.com>
 <53392EDA.7000904@intel.com>
 <alpine.DEB.2.00.1404070655530.28550@cobra.newdream.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.DEB.2.00.1404070655530.28550@cobra.newdream.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 07, 2014 at 06:56:28AM -0700, Sage Weil wrote:
> Hi Al,
> 
> Can this go to Linus via your tree?

I believe this has been fixed by
da1ce0670c14d8380e423a3239e562a1dc15fa9e "vfs: add cross-rename".

Though probably the patch should still go in, possibly with a changelog
update.  We want it for stable kernels if nothing else.

--b.

> 
> Thanks!
> sage
> 
> 
> On Mon, 31 Mar 2014, Yan, Zheng wrote:
> 
> > Hi Al,
> > 
> > Could you include this in 3.15
> > 
> > Regards
> > Yan, Zheng
> > 
> > On 03/06/2014 10:35 PM, Trond Myklebust wrote:
> > > 
> > > On Mar 6, 2014, at 9:16, Yan, Zheng <zheng.z.yan@intel.com> wrote:
> > > 
> > >> From: David Howells <dhowells@redhat.com>
> > >>
> > >> Make __d_materialise_dentry() set the materialised dentry name correctly by
> > >> flipping the arguments to switch_names().
> > >>
> > >> switch_names() is lazy: if both names are internal to their dentries, it'll
> > >> overwrite that of the first dentry with that of the second, and won't update
> > >> that of the second.
> > >>
> > >> In the case of __d_materialise_dentry(), the second is an already extant
> > >> anonymous dentry that we want to insert into the tree in place of the dentry we
> > >> just looked up[*].  However, the dentry we just looked up carries the name we
> > >> actually want to use.
> > >>
> > >> [*] This is used by NFS to join a mount of a subtree into a mount of a tree
> > >> nearer the root when the two meet, where both mounts share a superblock and
> > >> thus a set of dentries.
> > >>
> > >> Signed-off-by: David Howells <dhowells@redhat.com>
> > >> ---
> > >> fs/dcache.c | 2 +-
> > >> 1 file changed, 1 insertion(+), 1 deletion(-)
> > >>
> > >> diff --git a/fs/dcache.c b/fs/dcache.c
> > >> index 265e0ce..ff779d4 100644
> > >> --- a/fs/dcache.c
> > >> +++ b/fs/dcache.c
> > >> @@ -2698,7 +2698,7 @@ static void __d_materialise_dentry(struct dentry *dentry, struct dentry *anon)
> > >>
> > >> 	dparent = dentry->d_parent;
> > >>
> > >> -	switch_names(dentry, anon);
> > >> +	switch_names(anon, dentry);
> > >> 	swap(dentry->d_name.hash, anon->d_name.hash);
> > >>
> > >> 	dentry->d_parent = dentry;
> > > 
> > > Well spotted...
> > > 
> > > We ought to better document the fact that ?switch_names? is asymmetrical. Perhaps change it to ?update_target_name?, and then switch the argument names so that the ?target? really is the thing that gets updated?
> > > 
> > > _________________________________
> > > Trond Myklebust
> > > Linux NFS client maintainer, PrimaryData
> > > trond.myklebust@primarydata.com
> > > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe ceph-devel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
