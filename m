Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54548 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754178Ab1HCRpn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 13:45:43 -0400
Message-ID: <4E398946.4080405@RedHat.com>
Date: Wed, 03 Aug 2011 13:45:42 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Matthew Treinish <treinish@linux.vnet.ibm.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] mountd: Fixed strcmp usage in in insert groups.
References: <1312225347-11282-1-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1312225347-11282-1-git-send-email-treinish@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/01/2011 03:02 PM, Matthew Treinish wrote:
> Fixed the usage of strcmp in the duplicate check in insert groups. Fixes an
> issue with showmount and other commands that required the group information.
> 
> Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
Committed... 

steved.

> ---
>  utils/mountd/mountd.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index 035624c..bcf5080 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -633,7 +633,7 @@ static void insert_group(struct exportnode *e, char *newname)
>  	struct groupnode *g;
>  
>  	for (g = e->ex_groups; g; g = g->gr_next)
> -		if (strcmp(g->gr_name, newname))
> +		if (!strcmp(g->gr_name, newname))
>  			return;
>  
>  	g = xmalloc(sizeof(*g));
