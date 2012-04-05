Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f174.google.com ([209.85.214.174]:44937 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755853Ab2DETrr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Apr 2012 15:47:47 -0400
MIME-Version: 1.0
In-Reply-To: <CADnza44gqDeLtZ9B6K3LVAxuyDc9dBh6uRpKrKbGeZ2+uHom_g@mail.gmail.com>
References: <CAPVoSvQ8M=VUjNCwd5=0ax9O1FOFruP33FcN-_NNPeE68J0FaQ@mail.gmail.com>
	<CADnza44gqDeLtZ9B6K3LVAxuyDc9dBh6uRpKrKbGeZ2+uHom_g@mail.gmail.com>
Date: Thu, 5 Apr 2012 21:47:47 +0200
Message-ID: <CAPVoSvQCA806f7igBWGF3aK6V5cVnFXEBZUut-nL3MEhPaCFjg@mail.gmail.com>
Subject: Re: 3.4-rc1:NFS Oops in nfs_clear_request_commit
From: Torsten Kaiser <just.for.lkml@googlemail.com>
To: Fred Isaman <faisaman4@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        LKML Kernel <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 5, 2012 at 9:31 PM, Fred Isaman <faisaman4@gmail.com> wrote:
> On Thu, Apr 5, 2012 at 2:55 PM, Torsten Kaiser
>> (gdb) list *0xffffffff81152d98
>> 0xffffffff81152d98 is in nfs_updatepage (fs/nfs/write.c:685).
>> 680                     req->wb_bytes = end - req->wb_offset;
>> 681             else
>> 682                     req->wb_bytes = rqend - req->wb_offset;
>> 683     out_unlock:
>> 684             spin_unlock(&inode->i_lock);
>> 685             nfs_clear_request_commit(req);
>> 686             return req;
>> 687     out_flushme:
>> 688             spin_unlock(&inode->i_lock);
>> 689             nfs_release_request(req);
>
> This was a simple failure to check for req==NULL after some recent
> code rearrangement.  I've just sent the patch to the linux-nfs list.

Thanks for the quick patch.
In hindsight its obvious how the NULL got into
nfs_clear_request_commit(), had I do not have to wonder if its fixed,
or if I'm just not seeing it again.

 648                 if (req == NULL)
 649                         goto out_unlock;
...
 683 out_unlock:
 684         spin_unlock(&inode->i_lock);
 685         nfs_clear_request_commit(req);

> I've copied and pasted below for reference, but there will probably be
> white space errors.

No problem, I can apply that minimal change by hand.

Thanks again, Torsten

> Fred
>
> 8<-------------------------------------------------------------------------------------------------------
>
> From 6a5223e5df12318d9f6bdc401634126271399f9b Mon Sep 17 00:00:00 2001
> From: Fred Isaman <iisaman@netapp.com>
> Date: Thu, 5 Apr 2012 15:24:04 -0400
> Subject: [PATCH 1/1] NFS: check for req==NULL in
> nfs_try_to_update_request cleanup
>
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/write.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 2c68818..9b8d4d4 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -682,7 +682,8 @@ static struct nfs_page
> *nfs_try_to_update_request(struct inode *inode,
>                req->wb_bytes = rqend - req->wb_offset;
>  out_unlock:
>        spin_unlock(&inode->i_lock);
> -       nfs_clear_request_commit(req);
> +       if (req)
> +               nfs_clear_request_commit(req);
>        return req;
>  out_flushme:
>        spin_unlock(&inode->i_lock);
> --
> 1.7.2.1
