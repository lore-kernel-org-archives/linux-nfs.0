Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27148 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754448Ab1HCRqn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Aug 2011 13:46:43 -0400
Message-ID: <4E398981.6030005@RedHat.com>
Date: Wed, 03 Aug 2011 13:46:41 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Matthew Treinish <treinish@linux.vnet.ibm.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] mountd: Removed duplicate check from insert_groups
References: <1312225347-11282-1-git-send-email-treinish@linux.vnet.ibm.com> <1312225347-11282-2-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1312225347-11282-2-git-send-email-treinish@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/01/2011 03:02 PM, Matthew Treinish wrote:
> Upon further inspection of mountd the duplicate check in insert group is not
> needed. It seems that export_read() already filters out duplicates so the
> check for duplicates again in insert groups isn't needed.
I think this check is still needed so for now I'm going to 
leave it...

steved.

> 
> Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
> ---
>  utils/mountd/mountd.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index bcf5080..9c27d6c 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -631,11 +631,6 @@ static exportnode *lookup_or_create_elist_entry(exports *elist, nfs_export *exp)
>  static void insert_group(struct exportnode *e, char *newname)
>  {
>  	struct groupnode *g;
> -
> -	for (g = e->ex_groups; g; g = g->gr_next)
> -		if (!strcmp(g->gr_name, newname))
> -			return;
> -
>  	g = xmalloc(sizeof(*g));
>  	g->gr_name = xstrdup(newname);
>  	g->gr_next = e->ex_groups;
