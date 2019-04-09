Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1158C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 20:50:12 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A9E0F2084B
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 20:50:12 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726479AbfDIUuM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 16:50:12 -0400
Received: from fieldses.org ([173.255.197.46]:38278 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726337AbfDIUuM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 16:50:12 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 6C7E73F4; Tue,  9 Apr 2019 16:50:11 -0400 (EDT)
Date:   Tue, 9 Apr 2019 16:50:11 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Kenneth D'souza <kdsouza@redhat.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs4_setfacl: Skip comment field while reading ACE(s).
Message-ID: <20190409205011.GD29099@fieldses.org>
References: <20190326141109.16844-1-kdsouza@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190326141109.16844-1-kdsouza@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Applied, with some fixes:

On Tue, Mar 26, 2019 at 07:41:09PM +0530, Kenneth D'souza wrote:
> With commit 6630629bb661a7f48fb9856f7fd9616ce1499efa an additional field for filename
> was added due to which nfs4_setfacl failed to handle comments while reading ACE(s)
> from nfs4_getfacl output.
> This patch resolves the issue by skipping comment header.
> 
>  With fix:
> 
>  $ nfs4_setfacl --test -s "$(nfs4_getfacl  file1)" file2
>  Skipping comment # file: file1

Just skip it silently, there's not need to print anything.

>  ## Test mode only - the resulting ACL for "/test/file2":
>  A::OWNER@:rwatTcCy
>  A:g:GROUP@:rtcy
>  A::EVERYONE@:rtcy
> 
>  Without fix:
> 
>  $ nfs4_setfacl --test -s "$(nfs4_getfacl  file1)" file2
>  Failed while inserting ACE(s).
> 
> Signed-off-by: Kenneth D'souza <kdsouza@redhat.com>
> ---
>  libnfs4acl/nfs4_insert_string_aces.c | 16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
> 
> diff --git a/libnfs4acl/nfs4_insert_string_aces.c b/libnfs4acl/nfs4_insert_string_aces.c
> index 5a482d5..50b7bbf 100644
> --- a/libnfs4acl/nfs4_insert_string_aces.c
> +++ b/libnfs4acl/nfs4_insert_string_aces.c
> @@ -45,21 +45,25 @@ int nfs4_insert_string_aces(struct nfs4_acl *acl, const char *acl_spec, unsigned
>  	if ((s = sp = strdup(acl_spec)) == NULL)
>  		goto out_failed;
>  
> +
>  	while ((ssp = strsep(&sp, ",\t\n\r")) != NULL) {
>  		if (!strlen(ssp))
>  			continue;
>  
> -		if ((ace = nfs4_ace_from_string(ssp, acl->is_directory)) == NULL)
> -			goto out_failed;
> +		if(*ssp == '#')
> +			printf("Skipping comment %s\n", ssp);

So let's just do a "continue" here, as above.  Also notice we usually
leave a space after "if".

--b.

> +		else {
> +			if ((ace = nfs4_ace_from_string(ssp, acl->is_directory)) == NULL)
> +				goto out_failed;
>  
> -		if (nfs4_insert_ace_at(acl, ace, index++)) {
> -			free(ace);
> -			goto out_failed;
> +			if (nfs4_insert_ace_at(acl, ace, index++)) {
> +				free(ace);
> +				goto out_failed;
> +			}
>  		}
>  	}
>  	if (acl->naces == 0)
>  		goto out_failed;
> -
>  out:
>  	if (s)
>  		free(s);
> -- 
> 2.20.1
