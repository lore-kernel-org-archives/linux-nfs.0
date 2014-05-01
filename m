Return-Path: linux-nfs-owner@vger.kernel.org
Received: from a-pb-sasl-quonix.pobox.com ([208.72.237.25]:57429 "EHLO
	smtp.pobox.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751114AbaEALun (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 07:50:43 -0400
Message-ID: <5362350A.6040402@pobox.com>
Date: Thu, 01 May 2014 07:50:34 -0400
From: Mark Lord <mlord@pobox.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>
CC: "J. Bruce Fields" <bfields@redhat.com>, Albert Fluegel <af@muc.de>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
References: <533D8D73.1090603@pobox.com> <20140403171643.GB28790@pad.redhat.com> <533D9F8A.6030001@pobox.com> <20140403145504.3b04170e@tlielax.poochiereds.net> <20140403201627.GC8343@fieldses.org> <20140403192146.79679909@tlielax.poochiereds.net> <20140404135842.GB17594@fieldses.org>
In-Reply-To: <20140404135842.GB17594@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14-04-04 09:58 AM, J. Bruce Fields wrote:
> On Thu, Apr 03, 2014 at 07:21:46PM -0400, Jeff Layton wrote:
>> So according to the RFC you have to encode both the mode bits and the
>> ftype for v2. The type bits seem to be removed from the mode in NFSv3
>> though, so perhaps we should only be doing that masking in versions
>> above v2?
> 
> Right, the problematic patch applied the same mask in both v2 and v3
> cases, so I'm reverting just the v2 part (see below).
> 
>> With a quick check, it looks like the v3 code doesn't rely on those bits
>> and I imagine v4 doesn't either.
>>
>> It might also be nice to have the client v2 decode_fattr function to
>> throw a warning if the server sends us mismatched type bits and ftype
>> values. That would have helped us catch this sooner...
> 
> Yes, that might be a reasonable thing to do, though I don't know if it's
> worth it.
> 
> --b.
> 
> commit 35a8dff14e76c00e5b52140290cfb498dc2454a0
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Apr 3 15:10:35 2014 -0400
> 
>     nfsd: revert v2 half of "nfsd: don't return high mode bits"
>     
>     This reverts the part of commit 6e14b46b91fee8a049b0940333ce13a820beaaa5
>     that changes NFSv2 behavior.
>     
>     Mark Lord found that it broke nfs-root for Linux clients, because it
>     broke NFSv2.
>     
>     In fact, from RFC 1094:
>     
>     	"Notice that the file type is specified both in the mode bits
>     	and in the file type.  This is really a bug in the protocol and
>     	will be fixed in future versions."
>     
>     So NFSv2 clients really are expected to depend on the high bits of the
>     mode.
>     
>     Cc: stable@kernel.org
>     Reported-by: Mark Lord <mlord@pobox.com>
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
> index b17d932..9c769a4 100644
> --- a/fs/nfsd/nfsxdr.c
> +++ b/fs/nfsd/nfsxdr.c
> @@ -152,7 +152,7 @@ encode_fattr(struct svc_rqst *rqstp, __be32 *p, struct svc_fh *fhp,
>  	type = (stat->mode & S_IFMT);
>  
>  	*p++ = htonl(nfs_ftypes[type >> 12]);
> -	*p++ = htonl((u32) (stat->mode & S_IALLUGO));
> +	*p++ = htonl((u32) stat->mode);
>  	*p++ = htonl((u32) stat->nlink);
>  	*p++ = htonl((u32) from_kuid(&init_user_ns, stat->uid));
>  	*p++ = htonl((u32) from_kgid(&init_user_ns, stat->gid));
> 


Still a regression in 3.14.2 now.
Anyone got plans to push this patch out to mainline, as well as +stable ?

-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com
