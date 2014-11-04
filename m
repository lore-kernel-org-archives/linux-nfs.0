Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:55010 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752379AbaKDThy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2014 14:37:54 -0500
Message-ID: <54592B0E.5050201@RedHat.com>
Date: Tue, 04 Nov 2014 14:37:50 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Benjamin Coddington <bcodding@redhat.com>, linux-nfs@vger.kernel.org
CC: chuck.lever@oracle.com
Subject: Re: [PATCH v2] nfsidmap: keyctl_invalidate kernel compatibility
References: <eee96450255a3407517dd1ed4ce9991ba9f2dbd1.1415034378.git.bcodding@redhat.com>
In-Reply-To: <eee96450255a3407517dd1ed4ce9991ba9f2dbd1.1415034378.git.bcodding@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/03/2014 12:12 PM, Benjamin Coddington wrote:
> Change the keyctl_invalidate call to use the syscall interface directly so
> that when building with libkeyutils missing keyctl_invalidate the build succeeds.
> Attempt to use _invalidate and fall back to _revoke if the current kernel is
> missing _invalidate.
> 
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
Committed... 

This does get by the nfsidmap compile error when 
compiling on RHEL6, but not the ones in nfsdcltrack/sqlite.c
(http://ur1.ca/ioyfs)

Chuck, how are you getting around them?

steved.

> ---
>  utils/nfsidmap/nfsidmap.c |   21 +++++++++++++++++----
>  1 files changed, 17 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
> index e0d31e7..96149cc 100644
> --- a/utils/nfsidmap/nfsidmap.c
> +++ b/utils/nfsidmap/nfsidmap.c
> @@ -209,10 +209,23 @@ static int key_invalidate(char *keystr, int keymask)
>  		*(strchr(buf, ' ')) = '\0';
>  		sscanf(buf, "%x", &key);
>  
> -		if (keyctl_invalidate(key) < 0) {
> -			xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
> -			fclose(fp);
> -			return 1;
> +/* older libkeyutils compatibility */
> +#ifndef KEYCTL_INVALIDATE
> +#define KEYCTL_INVALIDATE 21      /* invalidate a key */
> +#endif
> +		if (keyctl(KEYCTL_INVALIDATE, key) < 0) {
> +			if (errno != EOPNOTSUPP) {
> +				xlog_err("keyctl_invalidate(0x%x) failed: %m", key);
> +				fclose(fp);
> +				return 1;
> +			} else {
> +				/* older kernel compatibility attempt: */
> +				if (keyctl_revoke(key) < 0) {
> +					xlog_err("keyctl_revoke(0x%x) failed: %m", key);
> +					fclose(fp);
> +					return 1;
> +				}
> +			}
>  		}
>  
>  		keymask &= ~mask;
> 
