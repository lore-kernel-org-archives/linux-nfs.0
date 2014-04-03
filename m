Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1.start.ca ([64.140.120.57]:44347 "EHLO mail1.start.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679AbaDCQoh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Apr 2014 12:44:37 -0400
Message-ID: <533D8FE9.80309@pobox.com>
Date: Thu, 03 Apr 2014 12:44:25 -0400
From: Mark Lord <mlord@pobox.com>
MIME-Version: 1.0
To: Albert Fluegel <af@muc.de>, "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: linux-3.14 nfsd regression
References: <533D8D73.1090603@pobox.com>
In-Reply-To: <533D8D73.1090603@pobox.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14-04-03 12:33 PM, Mark Lord wrote:
> This commit from linux-3.14 breaks our NFS-root clients here:
> 
> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=6e14b46b91fee8a049b0940333ce13a820beaaa5
> 
> 
> - *p++ = htonl((u32) stat->mode);
> + *p++ = htonl((u32) (stat->mode & S_IALLUGO));
> 
> 
> Reverting the one-liner above (on the server) fixes it for us,
> as does reverting back to linux-3.13.8 on the server.
> 
> The NFS-root clients are on PowerPC (big-endian) architecture,
> running linux-3.12.16. The NFS server is on an Intel PC running linux-3.14.
> 
> ACL is completely disabled on server and client,
> and we're using NFSv2/v3.  No support for v4.
> 
> I instrumented the function to see what other bits were being cleared
> by the (stat->mode & S_IALLUGO) masking.  The results are attached.
..


Looking into the (previously attached) trace, the bits that seem to be
getting chopped most often are S_IFREG (0x8000) and S_IFDIR (0x4000).
It appears that one/both of those are needed for mounting nfsroot.


[ 2733.823753] encode_fattr: mode=0x000041ed mask=0x00000fff
[ 2733.824217] encode_fattr: mode=0x000041ed mask=0x00000fff
[ 2733.838769] encode_fattr: mode=0x000041ed mask=0x00000fff
[ 2733.839175] encode_fattr: mode=0x0000a1ff mask=0x00000fff
[ 2733.839895] encode_fattr: mode=0x000081ed mask=0x00000fff
[ 2733.840388] encode_fattr: mode=0x000081ed mask=0x00000fff
[ 2733.840431] encode_fattr: mode=0x000081ed mask=0x00000fff
[ 2733.841256] encode_fattr: mode=0x000041ed mask=0x00000fff
[ 2733.841659] encode_fattr: mode=0x0000a1ff mask=0x00000fff
[ 2733.842379] encode_fattr: mode=0x000081ed mask=0x00000fff
[ 2733.842825] encode_fattr: mode=0x000081ed mask=0x00000fff
[ 2733.842879] encode_fattr: mode=0x000081ed mask=0x00000fff
[ 2733.843876] encode_fattr: mode=0x000081ed mask=0x00000fff
[ 2733.843924] encode_fattr: mode=0x000081ed mask=0x00000fff
...
