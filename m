Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:31531 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757066AbaD2AUn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 20:20:43 -0400
Date: Tue, 29 Apr 2014 10:20:13 +1000
From: Dave Chinner <david@fromorbit.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        viro@zeniv.linux.org.uk, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V1 09/22] vfs: Make acl_permission_check() work for
 richacls
Message-ID: <20140429002013.GR15995@dastard>
References: <1398615293-22931-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1398615293-22931-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1398615293-22931-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Apr 27, 2014 at 09:44:40PM +0530, Aneesh Kumar K.V wrote:
> From: Andreas Gruenbacher <agruen@kernel.org>
> 
> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  fs/namei.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 26b9a8212837..06474553c08d 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -284,6 +284,19 @@ static int acl_permission_check(struct inode *inode, int mask)
>  {
>  	unsigned int mode = inode->i_mode;
>  
> +	if (IS_RICHACL(inode)) {
> +		int error = check_acl(inode, mask);
> +		if (error != -EAGAIN)
> +			return error;
> +		if (mask & (MAY_DELETE_SELF | MAY_TAKE_OWNERSHIP |
> +			    MAY_CHMOD | MAY_SET_TIMES)) {
> +			/*
> +			 * The file permission bit cannot grant these
> +			 * permissions.
> +			 */
> +			return -EACCES;
> +		}
> +	}
>  	if (likely(uid_eq(current_fsuid(), inode->i_uid)))
>  		mode >>= 6;
>  	else {

why does this take priority over a simple uid match? Some comments
explaining this for people unfamiliar with richacls would be nice.
Not to mention the commit message should also explain the change...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
