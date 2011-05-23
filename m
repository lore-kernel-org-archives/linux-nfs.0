From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH v2] nfs-utils: getexportent interprets -test-client- as
 default options
Date: Mon, 23 May 2011 08:26:45 -0400
Message-ID: <4DDA5285.5090009@RedHat.com>
References: <4DD14CE9.1070301@RedHat.com> <20110518115537.8725.44754.stgit@nfs3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: Ben Myers <bpm@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859Ab1EWM0u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 May 2011 08:26:50 -0400
In-Reply-To: <20110518115537.8725.44754.stgit@nfs3>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/18/2011 07:55 AM, Ben Myers wrote:
> With commit 1374c3861abdc66f3a1410e26cc85f86760b51dd Neil added a
> -test-client- export to test the exportability of filesystems when exportfs
> is run.  When using the old cache controls (i.e. /proc/fs/nfsd is not
> mounted) exportfs will read /proc/fs/nfs/exports to process existing
> exports and find these test client entries.  The dash at the beginning of
> -test-client- will be cause getexportent to look for default options in the
> rest of the string, which test-client- will not match:
> 
> exportfs: /proc/fs/nfs/exports:1: unknown keyword "test-client-(rw"
> 
> This patch resolves that problem (as Steve suggested) by not processing any
> default options if we are reading the list of existing exports from the
> kernel.  Default options are converted to individual exports by exportfs so
> the kernel won't have any regardless.
> 
> Signed-off-by: Ben Myers <bpm@sgi.com>
> ---
>  support/nfs/exports.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 6acb2b6..c250383 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -142,9 +142,14 @@ getexportent(int fromkernel, int fromexports)
>  		return NULL;
>  	}
>  	first = 0;
> -		
> -	/* Check for default options */
> -	if (exp[0] == '-') {
> +
> +	/*
> +	 * Check for default options.  The kernel will never have default
> +	 * options in /proc/fs/nfs/exports, however due to the initial '-' in
> +	 * the -test-client- string from the test export we have to check that
> +	 * we're not reading from the kernel.
> +	 */
> +	if (exp[0] == '-' && !fromkernel) {
>  		if (parseopts(exp + 1, &def_ee, 0, &has_default_subtree_opts) < 0)
>  			return NULL;
>  		
> 
Committed...

steved.
