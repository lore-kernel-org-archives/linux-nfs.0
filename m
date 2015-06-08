Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f51.google.com ([209.85.216.51]:46766 "EHLO
	mail-vn0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584AbbFHVDY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 17:03:24 -0400
Received: by vnbf7 with SMTP id f7so19603124vnb.13
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jun 2015 14:03:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150608204734.GA27887@fieldses.org>
References: <1433453213-13466-1-git-send-email-trond.myklebust@primarydata.com>
	<1433453213-13466-2-git-send-email-trond.myklebust@primarydata.com>
	<1433453213-13466-3-git-send-email-trond.myklebust@primarydata.com>
	<CAHVgHyWz-dKX-6TbRCYRBp7b2uV2-kCd7U63sHd5ZKZKr6e7aw@mail.gmail.com>
	<B30A41CC-EADC-4738-8FDF-E8B03AAA48FC@oracle.com>
	<20150608204734.GA27887@fieldses.org>
Date: Mon, 8 Jun 2015 17:03:22 -0400
Message-ID: <CAHQdGtTeSTD0Meiq+9eT6HKGkwwD9aWAqusPQ74CYWgRAxZCrA@mail.gmail.com>
Subject: Re: [PATCH 3/6] SUNRPC: Clean up bc_send()
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        "William A. (Andy) Adamson" <androsadamson@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 8, 2015 at 4:47 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> I don't know, the above looks like pretty generic boilerplate, and I'd
> rather not accumulate a that kind of thing every time we move a
> significant piece of code around.  Could we compromise by adding a line
> or two to net/sunrpc/svc.c following the existing convention there?
> ("backchannel implementation originally (c) 2007 Network Appliance and
> (c) 2009 Netapp", or similar?)  Not a lawyer either, just looking for a
> way to keep it both honest and concise....
>

For significant contributions, we do sometimes allow contributors to
add a copyright notice. The other case where it is usually done is
when creating a new file, on the theory that the GPL does require that
code be copyrighted in order to be enforceable.

I'd suggest just a simple:

"Portions of this code are (c) 2007 Network Appliance, (c) 2009 NetApp".

Trond
