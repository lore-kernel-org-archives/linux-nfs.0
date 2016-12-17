Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57392 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751932AbcLQSnZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 17 Dec 2016 13:43:25 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id EC42D804FE
        for <linux-nfs@vger.kernel.org>; Sat, 17 Dec 2016 18:43:24 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] exportfs: fix path comparison in
 unexportfs_parsed()
To: Scott Mayhew <smayhew@redhat.com>
References: <1481830641-15595-1-git-send-email-smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <abe33732-e955-ffe1-4853-f2eb8a6f0c36@RedHat.com>
Date: Sat, 17 Dec 2016 13:43:24 -0500
MIME-Version: 1.0
In-Reply-To: <1481830641-15595-1-git-send-email-smayhew@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/15/2016 02:37 PM, Scott Mayhew wrote:
> Passing a path like /export1 to unexportfs_parsed() matches not only
> /export1, but /export11, /export100, /export1forthemoney, etc. which can
> result in some nasty surprises when unexporting individual exports.
> 
> Signed-off-by: Scott Mayhew <smayhew@redhat.com>
Committed... 

steved.

> ---
>  utils/exportfs/exportfs.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index b7a910e..a763272 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -345,6 +345,8 @@ unexportfs_parsed(char *hname, char *path, int verbose)
>  		nlen--;
>  
>  	for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
> +		if (strlen(exp->m_export.e_path) != nlen)
> +			continue;
>  		if (path && strncmp(path, exp->m_export.e_path, nlen))
>  			continue;
>  		if (htype != exp->m_client->m_type)
> -- 2.7.4
> 
