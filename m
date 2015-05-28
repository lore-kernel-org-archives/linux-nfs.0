Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vn0-f53.google.com ([209.85.216.53]:35766 "EHLO
	mail-vn0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932405AbbE1XLP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 May 2015 19:11:15 -0400
Received: by vnbf1 with SMTP id f1so6529703vnb.2
        for <linux-nfs@vger.kernel.org>; Thu, 28 May 2015 16:11:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <9fee05c37be52b8f8fcd5df05f391af9e3d820e8.1429868795.git.agruenba@redhat.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<9fee05c37be52b8f8fcd5df05f391af9e3d820e8.1429868795.git.agruenba@redhat.com>
Date: Thu, 28 May 2015 19:11:14 -0400
Message-ID: <CAHQdGtSUjeV_5UNFdgMQXXbRq2Fs+JTc6t-Dy2y1-hS4c49GOA@mail.gmail.com>
Subject: Re: [RFC v3 37/45] nfs/sunrpc: No more encode and decode function
 pointer casting
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
> Instead of casting the encode and decode functions to the required type when
> assigning them to the p_encode and p_decode members of struct rpc_procinfo,
> define the functions with their proper type and cast the additional obj
> argument to the appropriate type inside those functions. This allows slightly
> better type checking by the compiler at the cost of slightly more verbose code.

How is this even remotely relevant to ACL functionality, and why does
it deserve to bypass the NFS tree?

Trond
