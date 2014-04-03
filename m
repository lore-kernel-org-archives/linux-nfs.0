Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60876 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753509AbaDCUPg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 16:15:36 -0400
Date: Thu, 3 Apr 2014 16:15:33 -0400
To: Mark Lord <mlord@pobox.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, Albert Fluegel <af@muc.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
Message-ID: <20140403201533.GB8343@fieldses.org>
References: <533D8D73.1090603@pobox.com>
 <20140403171643.GB28790@pad.redhat.com>
 <533D9F8A.6030001@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <533D9F8A.6030001@pobox.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 03, 2014 at 01:51:06PM -0400, Mark Lord wrote:
> On 14-04-03 01:16 PM, J. Bruce Fields wrote:
> > The original behavior was in practice harmless and changing it broke
> > something, so I think we should definitely just revert this patch.
> 
> Yup.  Who?

I'll submit this soon.

--b.

Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Apr 3 15:10:35 2014 -0400

    nfsd: revert v2 half of "nfsd: don't return high mode bits"
    
    This reverts the part of commit 6e14b46b91fee8a049b0940333ce13a820beaaa5
    that changes NFSv2 behavior.
    
    Mark Lord found that it broke nfs-root for Linux clients, because it
    broke NFSv2.
    
    In fact, from RFC 1094:
    
    	"Notice that the file type is specified both in the mode bits
    	and in the file type.  This is really a bug in the protocol and
    	will be fixed in future versions."
    
    So NFSv2 clients really are expected to depend on the high bits of the
    mode.
    
    Cc: stable@kernel.org
    Reported-by: Mark Lord <mlord@pobox.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index b17d932..9c769a4 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -152,7 +152,7 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
 	type = (stat->mode & S_IFMT);
 
 	*p++ = htonl(nfs_ftypes[type >> 12]);
-	*p++ = htonl((u32) (stat->mode & S_IALLUGO));
+	*p++ = htonl((u32) stat->mode);
 	*p++ = htonl((u32) stat->nlink);
 	*p++ = htonl((u32) from_kuid(&init_user_ns, stat->uid));
 	*p++ = htonl((u32) from_kgid(&init_user_ns, stat->gid));
