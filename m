Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59588 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751678AbeEVQHv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 22 May 2018 12:07:51 -0400
Date: Tue, 22 May 2018 12:07:51 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@hammerspace.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: EVM HMAC and FS UUID
Message-ID: <20180522160751.GB30724@fieldses.org>
References: <04B6BFF9-AC1E-4E46-810B-7DDE5ED63345@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <04B6BFF9-AC1E-4E46-810B-7DDE5ED63345@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2018 at 08:53:34AM -0700, Chuck Lever wrote:
> Hi-
> 
> I'm continuing to look at NFS support for the Linux Integrity
> Measurement Architecture.
> 
> When computing an HMAC hash of file attributes, sometimes the
> FS UUID is included. For a client to verify that hash, the
> server will have to expose that UUID somehow.
> 
> Is there currently an NFSv4 attribute that carries the FS UUID?

I think the fsid is as close as you get.

Do you need to calculate hashes in exactly the way the server does?  If
you're assuming a "dumb server" that just stores signatures without
interpreting them, then maybe not?

--b.
