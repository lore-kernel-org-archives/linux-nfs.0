Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:2260 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754549Ab3IXTQw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Sep 2013 15:16:52 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r8OJGq3l023296
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 24 Sep 2013 15:16:52 -0400
Message-ID: <5241E540.7030102@RedHat.com>
Date: Tue, 24 Sep 2013 15:17:20 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCHv2 1/3] gssd: fix strncmp bug causing client removals
References: <1379624239-31199-2-git-send-email-bfields@redhat.com> <1379624632-31476-1-git-send-email-bfields@redhat.com>
In-Reply-To: <1379624632-31476-1-git-send-email-bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 19/09/13 17:03, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Both dirname and pdir are null-terminated strings, so there's no reason
> I can see for the strncmp.
> 
> And this gives the wrong result when comparing the "nfsd" and "nfsd4_cb"
> directories!  The results were callback clients being removed
> immediately after creation, when lack of a client with the corresponding
> name under "nfsd" lead gssd to believe it had disappeared from
> "nfsd4_cb".
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed...

steved.

> ---
>  utils/gssd/gssd_proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 2d3dbec..0383883 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -525,7 +525,7 @@ update_old_clients(struct dirent **namelist, int size, char *pdir)
>  		/* only compare entries in the global list that are from the
>  		 * same pipefs parent directory as "pdir"
>  		 */
> -		if (strncmp(clp->dirname, pdir, strlen(pdir)) != 0) continue;
> +		if (strcmp(clp->dirname, pdir) != 0) continue;
>  
>  		stillhere = 0;
>  		for (i=0; i < size; i++) {
> 
