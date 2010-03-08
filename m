From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2/3] mountd: trivial: name parameters for clarity
Date: Mon, 08 Mar 2010 15:04:51 -0500
Message-ID: <4B955863.9040505@RedHat.com>
References: <20100307200607.GA13006@fieldses.org> <1267992481-13332-1-git-send-email-bfields@citi.umich.edu> <1267992481-13332-2-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755540Ab0CHUEx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 15:04:53 -0500
In-Reply-To: <1267992481-13332-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/07/2010 03:08 PM, J. Bruce Fields wrote:
> Part of the reason for the previous bug was confusion between "subpath"
> and "path"; which is the shorter path, and which the longer?
> 
> "child" and "parent" seem less ambiguous.
> 
> Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> ---
>  utils/mountd/cache.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index ff27bbf..7dec468 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -614,12 +614,12 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
>  	return qword_eol(f);
>  }
>  
> -static int is_subdirectory(char *subpath, char *path)
> +static int is_subdirectory(char *child, char *parent)
>  {
> -	int l = strlen(path);
> +	int l = strlen(parent);
>  
> -	return strcmp(subpath, path) == 0
> -		|| (strncmp(subpath, path, l) == 0 && subpath[l] == '/');
> +	return strcmp(child, parent) == 0
> +		|| (strncmp(child, parent, l) == 0 && child[l] == '/');
>  }
>  
>  static int path_matches(nfs_export *exp, char *path)
Committed...

steved
