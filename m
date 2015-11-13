Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:36475 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbbKMR7I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Nov 2015 12:59:08 -0500
Received: by oiww189 with SMTP id w189so53794381oiw.3
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2015 09:59:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1447434029-28726-1-git-send-email-xerofoify@gmail.com>
References: <1447434029-28726-1-git-send-email-xerofoify@gmail.com>
Date: Fri, 13 Nov 2015 12:59:08 -0500
Message-ID: <CAHQdGtT6S0jMKK3RddK=os_Ga0Car_PHbOMy25=4zq3k3GFmrA@mail.gmail.com>
Subject: Re: [PATCH] nfs:Fix error checking in the function nfs4_proc_setattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Nicholas Krause <xerofoify@gmail.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 13, 2015 at 12:00 PM, Nicholas Krause <xerofoify@gmail.com> wrote:
> This fixes error checking in the function
> nfs4_proc_setattr to properly check and
> return a error code if the call to the
> function pnfs_commit_and_return_layout
> has failed by returning a error code
> as we cannot continue in the function
> nfs4_proc_settattr after this error
> code has been returned by the function,
> pnfs_commit_and_return.

Why not? It really is just advisory... On those architectures that
require it, the pNFS server still has a responsibility to recall any
outstanding layouts anyway when it receives a SETATTR call. The
pnfs_commit_and_return here should mainly be an optimisation to avoid
an unnecessary recall from the server, but we don't need to rely on
it.

Cheers
  Trond
