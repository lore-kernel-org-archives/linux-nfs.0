Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.3 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D268CC433C1
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Mar 2021 19:19:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A92EE61A2D
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Mar 2021 19:19:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230140AbhCYTTI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Mar 2021 15:19:08 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57928 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230032AbhCYTTE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Mar 2021 15:19:04 -0400
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 74507C06174A
        for <linux-nfs@vger.kernel.org>; Thu, 25 Mar 2021 12:19:04 -0700 (PDT)
Received: by fieldses.org (Postfix, from userid 2815)
        id 33E6528E5; Thu, 25 Mar 2021 15:19:03 -0400 (EDT)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 33E6528E5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1616699943;
        bh=Cvu9b31D2IQCWzxkGyTZZhQsA+Hr48lmT+ZGtT0YDfw=;
        h=Date:To:Cc:Subject:References:In-Reply-To:From:From;
        b=E4q5jHgX8rD8TzTG3oGBPbIy9Xovj4yRR2cn4a7L7zFmbXpnhGN8W1rZGHtW1zefv
         kgloAEZAzPTWr53eQwuOGxkSjIevbXtKiF0JKObBzsABWu6CJNRmJ8PqyF9iC6qfNq
         wzdrggjXIcjPhHr8hxuINSY5QkXkLETqOEF6BLmY=
Date:   Thu, 25 Mar 2021 15:19:03 -0400
To:     Ondrej Mosnacek <omosnace@redhat.com>
Cc:     Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] exportfs: fix unexporting of '/'
Message-ID: <20210325191903.GA18351@fieldses.org>
References: <20210322210238.96915-1-omosnace@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20210322210238.96915-1-omosnace@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Mar 22, 2021 at 10:02:38PM +0100, Ondrej Mosnacek wrote:
> The code that has been added to strip trailing slashes from path in
> unexportfs_parsed() forgot to account for the case of the root
> directory, which is simply '/'. In that case it accesses path[-1] and
> reduces the path to an empty string, which then fails to match any
> export.
> 
> Fix it by stopping the stripping when the path is just a single
> character - it doesn't matter if it's a '/' or not, we want to keep it
> either way in that case.

Makes sense to me.

(Note nfs-exporting / is often a bad idea.  I assume you had some good
reason in this case.)

--b.

> 
> Reproducer:
> 
>     exportfs localhost:/
>     exportfs -u localhost:/
> 
> Without this patch, the unexport step fails with "exportfs: Could not
> find 'localhost:/' to unexport."
> 
> Fixes: a9a7728d8743 ("exportfs: Deal with path's trailing "/" in unexportfs_parsed()")
> Link: https://bugzilla.redhat.com/show_bug.cgi?id=1941171
> Signed-off-by: Ondrej Mosnacek <omosnace@redhat.com>
> ---
>  utils/exportfs/exportfs.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
> index 262dd19a..1aedd3d6 100644
> --- a/utils/exportfs/exportfs.c
> +++ b/utils/exportfs/exportfs.c
> @@ -383,7 +383,7 @@ unexportfs_parsed(char *hname, char *path, int verbose)
>  	 * so need to deal with it.
>  	*/
>  	size_t nlen = strlen(path);
> -	while (path[nlen - 1] == '/')
> +	while (nlen > 1 && path[nlen - 1] == '/')
>  		nlen--;
>  
>  	for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
> -- 
> 2.30.2
