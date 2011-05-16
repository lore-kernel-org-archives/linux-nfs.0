Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756537Ab1EPQM3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 May 2011 12:12:29 -0400
Message-ID: <4DD14CE9.1070301@RedHat.com>
Date: Mon, 16 May 2011 12:12:25 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Ben Myers <bpm@sgi.com>
CC: neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: getexportent interprets -test-client- as default
 options
References: <20110512131810.25028.50931.stgit@nfs3>
In-Reply-To: <20110512131810.25028.50931.stgit@nfs3>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/12/2011 09:18 AM, Ben Myers wrote:
> With commit 1374c3861abdc66f3a1410e26cc85f86760b51dd Neil added a -test-client-
> export to test the exportability of filesystems when exportfs is run.  When
> using the old cache controls (i.e. /proc/fs/nfsd is not mounted) exportfs will
> read /proc/fs/nfs/exports and find these test client entries.  The dash at the
> beginning of -test-client- will be cause getexportent to look for default
> options in the rest of the string, which test-client- will not match:
> 
> exportfs: /proc/fs/nfs/exports:1: unknown keyword "test-client-(rw"
> 
> This patch resolves the problem by testing for -test-client- string in the
> check for default arguments.
> 
> Signed-off-by: Ben Myers <bpm@sgi.com>
> ---
>  support/nfs/exports.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/support/nfs/exports.c b/support/nfs/exports.c
> index 6acb2b6..7e29155 100644
> --- a/support/nfs/exports.c
> +++ b/support/nfs/exports.c
> @@ -142,9 +142,12 @@ getexportent(int fromkernel, int fromexports)
>  		return NULL;
>  	}
>  	first = 0;
> -		
> -	/* Check for default options */
> -	if (exp[0] == '-') {
> +
> +	/*
> +	 * Check for default options.  The test client string does not indicate
> +	 * default arguments.
> +	 */
> +	if (exp[0] == '-' && strncmp(exp, "-test-client-", 13) != 0) {
>  		if (parseopts(exp + 1, &def_ee, 0, &has_default_subtree_opts) < 0)
>  			return NULL;
If I'm understanding you correctly, when using the old cache controls
and when processing exports that are already exported (exports that 
are in /proc/fs/nfs/exports) will cause this problem.

If this indeed is the case, I think it's a bit cleaner if we
use the 'fromkernel' argument to decide if the '-' options
should or should not be processed. Something like:

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 6acb2b6..e4e9375 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -144,7 +144,7 @@ getexportent(int fromkernel, int fromexports)
        first = 0;
                
        /* Check for default options */
-       if (exp[0] == '-') {
+       if (exp[0] == '-' && !fromkernel) {
                if (parseopts(exp + 1, &def_ee, 0, &has_default_subtree_opts) < 0)
                        return NULL;

steved.





