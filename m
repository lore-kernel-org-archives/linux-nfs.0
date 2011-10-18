Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932768Ab1JRQIE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Oct 2011 12:08:04 -0400
Message-ID: <4E9DA462.8020704@RedHat.com>
Date: Tue, 18 Oct 2011 12:08:02 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Hamo <hamo.by@gmail.com>
CC: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: mount: really return from errno test
References: <CAO_0yfPgXJJSZNDYXHBSt45J0WQsh5EQVUs0nBN4wb+NoT6hAQ@mail.gmail.com>
In-Reply-To: <CAO_0yfPgXJJSZNDYXHBSt45J0WQsh5EQVUs0nBN4wb+NoT6hAQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/11/2011 05:44 AM, Hamo wrote:
> We should only try next address family if we meet ECONNREFUSED or EHOSTUNREACH
> for v4 or ECONNREFUSED or EOPNOTSUPP or EHOSTUNREACH for v3v2.
> Before, only a break in swich can not make the program out of for loop.
> 
> Signed-off-by: Yang Bai <hamo.by@gmail.com>
Committed....

steved.

> ---
>  utils/mount/stropts.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 314a806..4032bf3 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -665,9 +665,10 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
>  		case EHOSTUNREACH:
>  			continue;
>  		default:
> -			break;
> +			goto out;
>  		}
>  	}
> +out:
>  	return ret;
>  }
> 
> @@ -751,9 +752,10 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
>  		case EHOSTUNREACH:
>  			continue;
>  		default:
> -			break;
> +			goto out;
>  		}
>  	}
> +out:
>  	return ret;
>  }
> 
