Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:46515 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752579AbaKCPDW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2014 10:03:22 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH] nfsidmap: keyctl_invalidate kernel compatibility
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <643db7f6caed9ec25c0067aec85b97190bfbe174.1415026355.git.bcodding@redhat.com>
Date: Mon, 3 Nov 2014 10:03:17 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BBA57534-87D3-4403-A0C6-4E77E8FB1418@oracle.com>
References: <643db7f6caed9ec25c0067aec85b97190bfbe174.1415026355.git.bcodding@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 3, 2014, at 9:54 AM, Benjamin Coddington <bcodding@redhat.com> wrote:

> Change the keyctl_invalidate call to use the syscall interface directly so
> that when building with libkeyutils missing keyctl_invalidate the build succeeds.
> Attempt to use _invalidate and fall back to _revoke if the current kernel is
> missing _invalidate.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
> utils/nfsidmap/nfsidmap.c |   15 +++++++++++----
> 1 files changed, 11 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index e0d31e7..99ae07e 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -209,10 +209,17 @@ static int key_invalidate(char *keystr, int keymask)
> 		*(strchr(buf, ' ')) = '\0';
> 		sscanf(buf, "%x", &key);
> 
> -		if (keyctl_invalidate(key) < 0) {
> -			xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
> -			fclose(fp);
> -			return 1;
> +/* older libkeyutils compatibility */
> +#ifndef KEYCTL_INVALIDATE
> +#define KEYCTL_INVALIDATE 21      /* invalidate a key */
> +#endif
> +		if (keyctl(KEYCTL_INVALIDATE, key) < 0 && errno == EOPNOTSUPP) {
> +			/* older kernel compatibility attempt: */
> +			if (keyctl_revoke(key) < 0) {
> +				xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
> +				fclose(fp);
> +				return 1;
> +			}

Thanks, Ben.

This logic handles and reports errors only from keyctl_revoke().
Can it be updated to report errors (other than EOPNOTSUPP) from
either function, display the name of the keyctl function it
tried to invoke, and close fp and exit appropriately?


> 		}
> 
> 		keymask &= ~mask;
> -- 
> 1.7.1
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



