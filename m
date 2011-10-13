Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gy0-f174.google.com ([209.85.160.174]:59400 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751489Ab1JMCFj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Oct 2011 22:05:39 -0400
MIME-Version: 1.0
In-Reply-To: <CAO_0yfPgXJJSZNDYXHBSt45J0WQsh5EQVUs0nBN4wb+NoT6hAQ@mail.gmail.com>
References: <CAO_0yfPgXJJSZNDYXHBSt45J0WQsh5EQVUs0nBN4wb+NoT6hAQ@mail.gmail.com>
From: Hamo <hamo.by@gmail.com>
Date: Thu, 13 Oct 2011 10:05:19 +0800
Message-ID: <CAO_0yfNAFXKLomOSUd=Pun2_9+sot_uYNqBLC3ek8D5y-Xfypg@mail.gmail.com>
Subject: Re: [PATCH] nfs-utils: mount: really return from errno test
To: linux-nfs@vger.kernel.org
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        chuck.lever@oracle.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CC: Chuck Lever <chuck.lever@oracle.com>

On Tue, Oct 11, 2011 at 5:44 PM, Hamo <hamo.by@gmail.com> wrote:
> We should only try next address family if we meet ECONNREFUSED or EHOSTUNREACH
> for v4 or ECONNREFUSED or EOPNOTSUPP or EHOSTUNREACH for v3v2.
> Before, only a break in swich can not make the program out of for loop.
>
> Signed-off-by: Yang Bai <hamo.by@gmail.com>
> ---
>  utils/mount/stropts.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 314a806..4032bf3 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -665,9 +665,10 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
>                case EHOSTUNREACH:
>                        continue;
>                default:
> -                       break;
> +                       goto out;
>                }
>        }
> +out:
>        return ret;
>  }
>
> @@ -751,9 +752,10 @@ static int nfs_try_mount_v4(struct nfsmount_info *mi)
>                case EHOSTUNREACH:
>                        continue;
>                default:
> -                       break;
> +                       goto out;
>                }
>        }
> +out:
>        return ret;
>  }
>
> --
> 1.7.1
>



-- 
    """
    Keep It Simple,Stupid.
    """

Chinese Name: 白杨
Nick Name: Hamo
Homepage: http://hamobai.com/
GPG KEY ID: 0xA4691A33
Key fingerprint = 09D5 2D78 8E2B 0995 CF8E  4331 33C4 3D24 A469 1A33
