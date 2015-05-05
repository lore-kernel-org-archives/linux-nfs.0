Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47374 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992764AbbEENxA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 May 2015 09:53:00 -0400
Date: Tue, 5 May 2015 09:52:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: NeilBrown <neilb@suse.de>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Al Viro <viro@zeniv.linux.org.uk>, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150505135258.GA27106@fieldses.org>
References: <5538EB18.7080802@gmail.com>
 <20150424130045.6bbdb2f9@notabene.brown>
 <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <55483EB7.5060104@gmail.com>
 <20150505141957.2aef920e@notabene.brown>
 <55488006.6050502@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55488006.6050502@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 05, 2015 at 04:32:06PM +0800, Kinglong Mee wrote:
> -----------------------------------------------------------------------------------
> >From d831154bb7e527f9003e16ac049526be5ed90228 Mon Sep 17 00:00:00 2001
> From: Kinglong Mee <kinglongmee@gmail.com>
> Date: Tue, 5 May 2015 16:24:16 +0800
> Subject: [PATCH] mountd: Case-insensitive path length must equals to parent
> 
> Commit 6091c0a4c4 (mountd: add support for case-insensitive file names)
> introduces looking up bad path which is easy to trigger a present mutex race.

ACK to this patch.  (Steved, did you get this?)

--b.

> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> ---
>  utils/mountd/cache.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> index 7d250f9..155695a 100644
> --- a/utils/mountd/cache.c
> +++ b/utils/mountd/cache.c
> @@ -478,7 +478,7 @@ static int is_subdirectory(char *child, char *parent)
>  	if (strcmp(parent, "/") == 0 && child[1] != 0)
>  		return 1;
>  
> -	return (same_path(child, parent, l) && child[l] == '/');
> +	return (child[l] == '/'	&& same_path(child, parent, l));
>  }
>  
>  static int path_matches(nfs_export *exp, char *path)
> -- 
> 2.4.0
