Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:35321 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932474AbbE1Xk3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 19:40:29 -0400
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSUjeV_5UNFdgMQXXbRq2Fs+JTc6t-Dy2y1-hS4c49GOA@mail.gmail.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<9fee05c37be52b8f8fcd5df05f391af9e3d820e8.1429868795.git.agruenba@redhat.com>
	<CAHQdGtSUjeV_5UNFdgMQXXbRq2Fs+JTc6t-Dy2y1-hS4c49GOA@mail.gmail.com>
Date: Fri, 29 May 2015 01:40:28 +0200
Message-ID: <CAHpGcMKn1khdNTk=MFS7vFgLCHmxX2fVTJanertXT+Zj_BnAKA@mail.gmail.com>
Subject: Re: [RFC v3 37/45] nfs/sunrpc: No more encode and decode function
 pointer casting
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-29 1:11 GMT+02:00 Trond Myklebust <trond.myklebust@primarydata.com>:
> How is this even remotely relevant to ACL functionality, and why does
> it deserve to bypass the NFS tree?

I've posted this to the linux-nfs mailing list for review among
others, how is that
bypassing the NFS tree? Would you prefer those things sent to you personally
as well?

This patch prepares for for the next one which changes the prototype
of the encode
functions to return an error code. Without this patch, oversights in
the next patch
would go unnoticed; with this patch, the compiler will complain.

Thanks,
Andreas
