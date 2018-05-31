Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54454 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932451AbeEaApy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 May 2018 20:45:54 -0400
Date: Wed, 30 May 2018 20:45:54 -0400
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
Message-ID: <20180531004554.GA29116@fieldses.org>
References: <f74fae81-d1bc-1c0e-7b41-69502bd7c489@suse.de>
 <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
 <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de>
 <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
 <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 30, 2018 at 05:33:11AM -0500, Goldwyn Rodrigues wrote:
> I am not trying to override the security. I am trying to detect
> duplication of security information. The common case of NFS
> communication does not require the additional security parameters
> (doesn't mean it is not required). So my question is: is it possible to
> detect at the client that nfs4_acl is a duplicate of information which
> can be and is represented by inode alone. If yes, can it be suppressed
> by the client.

No, that's not possible.

The user's identity could be mapped in various ways.  You've got no way
to know whether root squashing is in effect, for example.  Or to know
what the user@EXAMPLE.COM krb5 identity that you're running as might map
to on the server.

So it's hard to even tell whether a given user matches the file's owner
or group.  So even the mode bits are kind of meaningless to the client.

--b.
