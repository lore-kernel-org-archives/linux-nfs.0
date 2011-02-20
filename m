Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:44595 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab1BTWk3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Feb 2011 17:40:29 -0500
Received: by ywj3 with SMTP id 3so554057ywj.19
        for <linux-nfs@vger.kernel.org>; Sun, 20 Feb 2011 14:40:28 -0800 (PST)
In-Reply-To: <1298241184-1250-1-git-send-email-imirkin@alum.mit.edu>
References: <1298241184-1250-1-git-send-email-imirkin@alum.mit.edu>
Date: Sun, 20 Feb 2011 22:40:28 +0000
Message-ID: <AANLkTinW069P9+gJwaLQnKR_eCbY1bM66J4k2KdvN9h0@mail.gmail.com>
Subject: Re: [PATCH] NFS: Zero entire acl2 structure
From: Ilia Mirkin <imirkin@alum.mit.edu>
To: Trond.Myklebust@netapp.com
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org,
        Ilia Mirkin <imirkin@alum.mit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Feb 20, 2011 at 10:33 PM, Ilia Mirkin <imirkin@alum.mit.edu> wrote:
> The semantic match that finds this problem:
> // <smpl>
> @@
> type T;
> identifier x;
> @@
>
> T *x;
> ...
> * memset(x, ..., ... * sizeof(x) * ...);
> // </smpl>
>
> Signed-off-by: Ilia Mirkin <imirkin@alum.mit.edu>
>
> ---
>  fs/nfs_common/nfsacl.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> Untested. But it's unlikely that the original intention was to only
> zero out the acl's refcount. However all of the acl's fields are
> explicitly initialized, so perhaps this can just be removed entirely.
> Unless the intention was to avoid leaking stack data in the structure's
> padding bytes.

Erm, nevermind. Looks like there already was a thread about this, with
the resolution to just remove the memset, but the patch just hadsn't
made it upstream yet.

-- 
Ilia Mirkin
imirkin@alum.mit.edu
