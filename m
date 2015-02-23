Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out03.mta.xmission.com ([166.70.13.233]:41806 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253AbbBWRN3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 12:13:29 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Wang YanQing <udknight@gmail.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
References: <20150223154419.GA2542@mwanda>
Date: Mon, 23 Feb 2015 11:10:02 -0600
In-Reply-To: <20150223154419.GA2542@mwanda> (Dan Carpenter's message of "Mon,
	23 Feb 2015 18:44:19 +0300")
Message-ID: <87385w1rmd.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [patch] groups: integer underflow in groups_alloc()
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> writes:

> This is called from rsc_parse() with a use controlled value.  Say for
> example that "gidsetsize" is negative, then we could end up allocating
> less than sizeof(struct group_info) leading to memory corruption.

Right now it is the responsibility of the caller of groups_alloc to make
certain that gidsetsize is a valid value, and the callers of
groups_alloc who know what they are doing already validate this value.

Either the pattern of caller validates the messages needs to continue,
or groups_alloc needs to be changed and all of the callers need to be
updated.

Changing groups_alloc for one particular caller is just going to cause
maintenance problems.

Eric


> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> I copied the NGROUPS_MAX limit from the surrounding code, I'm not
> absolutely that it's the correct limit to use.
>
> diff --git a/kernel/groups.c b/kernel/groups.c
> index 664411f..e9341b3 100644
> --- a/kernel/groups.c
> +++ b/kernel/groups.c
> @@ -18,6 +18,9 @@ struct group_info *groups_alloc(int gidsetsize)
>  	int nblocks;
>  	int i;
>  
> +	if ((unsigned)gidsetsize > NGROUPS_MAX)
> +		return NULL;
> +
>  	nblocks = (gidsetsize + NGROUPS_PER_BLOCK - 1) / NGROUPS_PER_BLOCK;
>  	/* Make sure we always allocate at least one indirect block pointer */
>  	nblocks = nblocks ? : 1;
