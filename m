Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752495Ab1F0QXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jun 2011 12:23:48 -0400
Message-ID: <4E08AE90.4050709@RedHat.com>
Date: Mon, 27 Jun 2011 12:23:44 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 1/2] add generated .c files to .gitignore
References: <cover.1308241259.git.rees@umich.edu> <ed7917ba1bcc8fd4537255c00e00b22eee4e7c88.1308241259.git.rees@umich.edu>
In-Reply-To: <ed7917ba1bcc8fd4537255c00e00b22eee4e7c88.1308241259.git.rees@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 06/16/2011 12:23 PM, Jim Rees wrote:
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  .gitignore |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/.gitignore b/.gitignore
> index f96c819..b8792d0 100644
> --- a/.gitignore
> +++ b/.gitignore
> @@ -15,6 +15,9 @@ basic/test8
>  basic/test9
>  domount
>  getopt
> +general/large1.c
> +general/large2.c
> +general/large3.c
>  lock/tlock64
>  lock/tlocklfs
>  special/bigfile
Committed on the git://linux-nfs.org/~steved/exports/cthon04 tree

steved.
