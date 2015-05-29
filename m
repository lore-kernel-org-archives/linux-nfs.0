Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f41.google.com ([209.85.216.41]:44565 "EHLO
	mail-vn0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755327AbbE2Ahb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 20:37:31 -0400
Received: by vnbg129 with SMTP id g129so6720702vnb.11
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2015 17:37:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHpGcMKn1khdNTk=MFS7vFgLCHmxX2fVTJanertXT+Zj_BnAKA@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<9fee05c37be52b8f8fcd5df05f391af9e3d820e8.1429868795.git.agruenba@redhat.com>
	<CAHQdGtSUjeV_5UNFdgMQXXbRq2Fs+JTc6t-Dy2y1-hS4c49GOA@mail.gmail.com>
	<CAHpGcMKn1khdNTk=MFS7vFgLCHmxX2fVTJanertXT+Zj_BnAKA@mail.gmail.com>
Date: Thu, 28 May 2015 20:37:30 -0400
Message-ID: <CAHQdGtRKLnMbB6Z5w7MCnONujHH2uBnx4VUrTL1GGfWTNwurRQ@mail.gmail.com>
Subject: Re: [RFC v3 37/45] nfs/sunrpc: No more encode and decode function
 pointer casting
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 28, 2015 at 7:40 PM, Andreas Grünbacher
<andreas.gruenbacher@gmail.com> wrote:
> 2015-05-29 1:11 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
>> How is this even remotely relevant to ACL functionality, and why does
>> it deserve to bypass the NFS tree?
>
> I've posted this to the linux-nfs mailing list for review among
> others, how is that
> bypassing the NFS tree? Would you prefer those things sent to you personally
> as well?

No. I'm saying that changes that affect the core RPC code should not
be going through external trees as part of an external feature; they
should go through the maintainer trees.

> This patch prepares for for the next one which changes the prototype
> of the encode
> functions to return an error code. Without this patch, oversights in
> the next patch
> would go unnoticed; with this patch, the compiler will complain.
>

See the comments to that patch too. There are precedents for doing
what you are trying to accomplish, and they do not require changes to
core code.

Trond
