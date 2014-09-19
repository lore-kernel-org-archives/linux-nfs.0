Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7143 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755904AbaISN1D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 09:27:03 -0400
Message-ID: <541C2F22.1030002@RedHat.com>
Date: Fri, 19 Sep 2014 09:26:58 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@primarydata.com>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 3/7] nfsdcltrack: rename CLD_* constants with CLTRACK_*
 prefixes
References: <1410789665-19745-1-git-send-email-jlayton@primarydata.com> <1410789665-19745-4-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1410789665-19745-4-git-send-email-jlayton@primarydata.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch does not compile do to the following errors:
   http://fpaste.org/134872/41113211/

With s/CLTRACK_SQLITE_LATEST_SCHEMA_VERSION/CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION/s
But this causes the 4 patch not to compile because  CLTRACK_SQLITE_LATEST_SCHEMA_VERSION
is not defined... 

Please straight this out, retest and resubmit!

steved.

On 09/15/2014 10:01 AM, Jeff Layton wrote:
> From: Jeff Layton <jlayton@poochiereds.net>
> 
> Since nfsdcld has been dead for a few years now, clean up the prefixes
> on the constants.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> ---
>  utils/nfsdcltrack/sqlite.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
> 
> diff --git a/utils/nfsdcltrack/sqlite.c b/utils/nfsdcltrack/sqlite.c
> index 352f029d55c0..52fcaa4d7ca3 100644
> --- a/utils/nfsdcltrack/sqlite.c
> +++ b/utils/nfsdcltrack/sqlite.c
> @@ -50,10 +50,10 @@
>  
>  #include "xlog.h"
>  
> -#define CLD_SQLITE_SCHEMA_VERSION 1
> +#define CLTRACK_SQLITE_LATEST_SCHEMA_VERSION 1
>  
>  /* in milliseconds */
> -#define CLD_SQLITE_BUSY_TIMEOUT 10000
> +#define CLTRACK_SQLITE_BUSY_TIMEOUT 10000
>  
>  /* private data structures */
>  
> @@ -111,7 +111,7 @@ sqlite_prepare_dbh(const char *topdir)
>  		return ret;
>  	}
>  
> -	ret = sqlite3_busy_timeout(dbh, CLD_SQLITE_BUSY_TIMEOUT);
> +	ret = sqlite3_busy_timeout(dbh, CLTRACK_SQLITE_BUSY_TIMEOUT);
>  	if (ret != SQLITE_OK) {
>  		xlog(L_ERROR, "Unable to set sqlite busy timeout: %d", ret);
>  		sqlite3_close(dbh);
> @@ -156,7 +156,7 @@ sqlite_maindb_init(const char *topdir)
>  	/* insert version into table -- ignore error if it fails */
>  	ret = snprintf(buf, sizeof(buf),
>  		       "INSERT OR IGNORE INTO parameters values (\"version\", "
> -		       "\"%d\");", CLD_SQLITE_SCHEMA_VERSION);
> +		       "\"%d\");", CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION);
>  	if (ret < 0) {
>  		goto out_err;
>  	} else if ((size_t)ret >= sizeof(buf)) {
> @@ -189,10 +189,10 @@ sqlite_maindb_init(const char *topdir)
>  
>  	/* process SELECT result */
>  	ret = sqlite3_column_int(stmt, 0);
> -	if (ret != CLD_SQLITE_SCHEMA_VERSION) {
> +	if (ret != CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION) {
>  		xlog(L_ERROR, "Unsupported database schema version! "
>  			"Expected %d, got %d.",
> -			CLD_SQLITE_SCHEMA_VERSION, ret);
> +			CLTRACK_SQLITE_CURRENT_SCHEMA_VERSION, ret);
>  		ret = -EINVAL;
>  		goto out_err;
>  	}
> 
