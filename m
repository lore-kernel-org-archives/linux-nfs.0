Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:42468 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755123AbaEHRnu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 13:43:50 -0400
Received: by mail-qg0-f44.google.com with SMTP id i50so3156403qgf.17
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 10:43:50 -0700 (PDT)
Date: Thu, 8 May 2014 13:43:47 -0400
From: Jeff Layton <jlayton@poochiereds.net>
To: Thomas Haynes <thomas.haynes@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Push the file layout driver into a subdirectory
Message-ID: <20140508134347.0c330f62@tlielax.poochiereds.net>
In-Reply-To: <1399560525-1913-1-git-send-email-Thomas.Haynes@primarydata.com>
References: <1399560525-1913-1-git-send-email-Thomas.Haynes@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  8 May 2014 07:48:44 -0700
Thomas Haynes <thomas.haynes@primarydata.com> wrote:

> From: Tom Haynes <Thomas.Haynes@primarydata.com>
> 
> The object and block layouts already exist in their own
> subdirectories. This patch completes the set!
> 
> Note that as a layout denotes nfs4 already, I stripped
> that prefix out of the file names.
> 
> The patch looks longer than it really is, but git
> logs are preserved. :-)
> 
> Tom Haynes (1):
>   Push the file layout driver into a subdirectory
> 
>  fs/nfs/Makefile                   |    4 +-
>  fs/nfs/filelayout/Kbuild          |    5 +
>  fs/nfs/filelayout/filelayout.c    | 1391 +++++++++++++++++++++++++++++++++++++
>  fs/nfs/filelayout/filelayout.h    |  156 +++++
>  fs/nfs/filelayout/filelayoutdev.c |  843 ++++++++++++++++++++++
>  fs/nfs/nfs4filelayout.c           | 1391 -------------------------------------
>  fs/nfs/nfs4filelayout.h           |  156 -----
>  fs/nfs/nfs4filelayoutdev.c        |  843 ----------------------
>  8 files changed, 2396 insertions(+), 2393 deletions(-)
>  create mode 100644 fs/nfs/filelayout/Kbuild
>  create mode 100644 fs/nfs/filelayout/filelayout.c
>  create mode 100644 fs/nfs/filelayout/filelayout.h
>  create mode 100644 fs/nfs/filelayout/filelayoutdev.c
>  delete mode 100644 fs/nfs/nfs4filelayout.c
>  delete mode 100644 fs/nfs/nfs4filelayout.h
>  delete mode 100644 fs/nfs/nfs4filelayoutdev.c
> 

Erm, the diffstat looks nice, but where's the patch? ;)
-- 
Jeff Layton <jlayton@poochiereds.net>
