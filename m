From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/3] mountd: fix path comparison for v4 crossmnt
Date: Mon, 08 Mar 2010 15:04:35 -0500
Message-ID: <4B955853.1030103@RedHat.com>
References: <20100307200607.GA13006@fieldses.org> <1267992481-13332-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755523Ab0CHUEh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 15:04:37 -0500
In-Reply-To: <1267992481-13332-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2010 03:07 PM, J. Bruce Fields wrote:
> This was obviously wrong, since path[strlen(path)] == '\0' should always
> be true.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  utils/mountd/cache.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index d63e10a..ff27bbf 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -619,7 +619,7 @@ static int is_subdirectory(char *subpath, char *path)
>  	int l = strlen(path);
>  
>  	return strcmp(subpath, path) == 0
> -		|| (strncmp(subpath, path, l) == 0 && path[l] == '/');
> +		|| (strncmp(subpath, path, l) == 0 && subpath[l] == '/');
>  }
>  
>  static int path_matches(nfs_export *exp, char *path)
Committed...

steved.
