Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f52.google.com ([209.85.216.52]:41228 "EHLO
	mail-vn0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbbE1Xjy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 19:39:54 -0400
Received: by vnbg62 with SMTP id g62so6656241vnb.8
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2015 16:39:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9c755df47acdef7f6a1d0195af888dafb7d3e7bf.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<9c755df47acdef7f6a1d0195af888dafb7d3e7bf.1429868795.git.agruenba@redhat.com>
Date: Thu, 28 May 2015 19:39:54 -0400
Message-ID: <CAHQdGtTEhYWcVaahYx_ajsp8-V0GEF7NEU7cPnLUQz+pCzuniA@mail.gmail.com>
Subject: Re: [RFC v3 38/45] nfs/sunrpc: Return status code from encode functions
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 7:04 AM, Andreas Gruenbacher
<andreas.gruenbacher@gmail.com> wrote:
> Return a status code from the sunrpc xdr encode functions. While these
> functions were originally returning a status code before commit 9f06c719 from
> December 2010, it was found that none of them can actually fail and so they
> were turned into void functions. With more complex objects like NFSv4 ACLs to
> encode, it makes sense to do memory allocations and some of the error checking
> inside the encode functions, so those functions may fail.


The standard way to do this is to allocate the xdr buffer and perform
the xdr encoding outside the RPC call itself. Please see the
layoutcommit function, for instance.

Trond
