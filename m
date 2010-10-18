Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54377 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755586Ab0JRPBk convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Oct 2010 11:01:40 -0400
Date: Mon, 18 Oct 2010 11:01:38 -0400
From: Jeff Layton <jlayton@redhat.com>
To: =?ISO-8859-1?B?Q2zhdWRpbw==?= Martins <ctpm@ist.utl.pt>
Cc: Ian Munsie <imunsie@au1.ibm.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NFS sillyrename side effect
Message-ID: <20101018110138.5f5001eb@corrin.poochiereds.net>
In-Reply-To: <20101018155344.6e50dbb9.ctpm@ist.utl.pt>
References: <1287362142-sup-777@au1.ibm.com>
	<20101018101059.574b715a@corrin.poochiereds.net>
	<20101018154811.768baeb5.ctpm@ist.utl.pt>
	<20101018155344.6e50dbb9.ctpm@ist.utl.pt>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 18 Oct 2010 15:53:44 +0100
Cláudio Martins <ctpm@ist.utl.pt> wrote:

> 
> On Mon, 18 Oct 2010 15:48:11 +0100 Cláudio Martins <ctpm@ist.utl.pt> wrote:
> > 
> >  Section D2 ends with:
> > 
> > "The NFS version 4 protocol is stateful, and could actually support
> > delete-on-last-close. Unfortunately there isn't an easy way to do this
> > and remain backwards-compatible with version 2 and 3 accessors."
> > 
> >  So, theoretically, could one modify the code to selectively disable
> > silly rename on a client, when it knows it is talking v4 with the
> > server?
> > 
> 
>  BTW, to clarify, I'm assuming a scenario where the server is
> configured to talk v4 only, which I suspect should be common, at least
> when you're relying on v4 kerberos security.
> 

Sadly, no...

The server does generally hold the file open as long as the client has
the file open. So, you could delete the file while nfsd has it open and
everything would probably still work.

Suppose though that the server crashes and reboots. When it comes back
up, fsck figures out that the file has been unlinked and frees the
blocks on the disk. Now you can't reclaim the state on the open file.

We're pretty much stuck with silly-renaming even for v4.

-- 
Jeff Layton <jlayton@redhat.com>
