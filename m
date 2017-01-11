Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57196 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966936AbdAKOQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 09:16:51 -0500
Date: Wed, 11 Jan 2017 09:16:50 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] exportfs: Make sure pass all valid export flags to nfsd
Message-ID: <20170111141650.GA18977@fieldses.org>
References: <c0826298-545e-64a3-b6bb-86413bf9eb39@gmail.com>
 <20170106210531.GB31401@fieldses.org>
 <49b7be0a-548a-cff1-8f09-613cd5c63141@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <49b7be0a-548a-cff1-8f09-613cd5c63141@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 07, 2017 at 07:57:28PM +0800, Kinglong Mee wrote:
> On 1/7/2017 05:05, J. Bruce Fields wrote:
> > On Sat, Dec 31, 2016 at 09:05:11PM +0800, Kinglong Mee wrote:
> >> test_export pass a export flags only marks NFSEXP_FSID,
> >> nfsd may want other flags for export checking.
> > 
> > Why?  What problem does this fix?
> 
> When testing the patch "NFSD: Only support readonly export for
> !fsync and readonly filesystem", I found exportfs don't pass 
> all valid export flags to nfsd. So, make this patch.

This function is meant to test whether a filesystem supports nfs export
or not.  It doesn't need the full set of export flags.  Off the top of
my head I can't see reason this would cause problems, but I'm not
convinced it's safe, either.  (New nfs-utils against old kernels might
be a case to check, e.g. to see how unsupported flags are handled.)

So until we have a reason we *need* this, just to be safe, I'd prefer to
revert this patch.

--b.

> 
> thanks,
> Kinglong Mee
> 
> > 
> > --b.
> > 
> >> This patch make sure exportfs pass all other flags to nfsd.
> >>
> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >> ---
> >>  utils/exportfs/exportfs.c | 12 +++++++-----
> >>  1 file changed, 7 insertions(+), 5 deletions(-)
> >>
> >> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> >> index 15a1583..bacf106 100644
> >> --- a/utils/exportfs/exportfs.c
> >> +++ b/utils/exportfs/exportfs.c
> >> @@ -473,8 +473,10 @@ static int can_test(void)
> >>  	return 1;
> >>  }
> >>  
> >> -static int test_export(char *path, int with_fsid)
> >> +static int test_export(nfs_export *exp, int with_fsid)
> >>  {
> >> +	char *path = exp->m_export.e_path;
> >> +	int flags = exp->m_export.e_flags | (with_fsid ? NFSEXP_FSID : 0);
> >>  	/* beside max path, buf size should take protocol str into account */
> >>  	char buf[NFS_MAXPATHLEN+1+64] = { 0 };
> >>  	char *bp = buf;
> >> @@ -487,7 +489,7 @@ static int test_export(char *path, int with_fsid)
> >>  	qword_add(&bp, &len, path);
> >>  	if (len < 1)
> >>  		return 0;
> >> -	snprintf(bp, len, " 3 %d 65534 65534 0\n", with_fsid ? NFSEXP_FSID : 0);
> >> +	snprintf(bp, len, " 3 %d 65534 65534 0\n", flags);
> >>  	fd = open("/proc/net/rpc/nfsd.export/channel", O_WRONLY);
> >>  	if (fd < 0)
> >>  		return 0;
> >> @@ -529,12 +531,12 @@ validate_export(nfs_export *exp)
> >>  
> >>  	if ((exp->m_export.e_flags & NFSEXP_FSID) || exp->m_export.e_uuid ||
> >>  	    fs_has_fsid) {
> >> -		if ( !test_export(path, 1)) {
> >> +		if ( !test_export(exp, 1)) {
> >>  			xlog(L_ERROR, "%s does not support NFS export", path);
> >>  			return;
> >>  		}
> >> -	} else if ( ! test_export(path, 0)) {
> >> -		if (test_export(path, 1))
> >> +	} else if ( !test_export(exp, 0)) {
> >> +		if (test_export(exp, 1))
> >>  			xlog(L_ERROR, "%s requires fsid= for NFS export", path);
> >>  		else
> >>  			xlog(L_ERROR, "%s does not support NFS export", path);
> >> -- 
> >> 2.9.3
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
