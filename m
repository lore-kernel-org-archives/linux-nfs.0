Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48504 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985Ab0JRRK3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Oct 2010 13:10:29 -0400
Date: Mon, 18 Oct 2010 13:10:15 -0400
To: Jeff Layton <jlayton@redhat.com>
Cc: =?utf-8?Q?Cl=C3=A1udio?= Martins <ctpm@ist.utl.pt>,
        Ian Munsie <imunsie@au1.ibm.com>,
        Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: NFS sillyrename side effect
Message-ID: <20101018171015.GB3744@fieldses.org>
References: <1287362142-sup-777@au1.ibm.com>
 <20101018101059.574b715a@corrin.poochiereds.net>
 <20101018154811.768baeb5.ctpm@ist.utl.pt>
 <20101018155344.6e50dbb9.ctpm@ist.utl.pt>
 <20101018110138.5f5001eb@corrin.poochiereds.net>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20101018110138.5f5001eb@corrin.poochiereds.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Oct 18, 2010 at 11:01:38AM -0400, Jeff Layton wrote:
> On Mon, 18 Oct 2010 15:53:44 +0100
> Cláudio Martins <ctpm@ist.utl.pt> wrote:
> 
> > 
> > On Mon, 18 Oct 2010 15:48:11 +0100 Cláudio Martins <ctpm@ist.utl.pt> wrote:
> > > 
> > >  Section D2 ends with:
> > > 
> > > "The NFS version 4 protocol is stateful, and could actually support
> > > delete-on-last-close. Unfortunately there isn't an easy way to do this
> > > and remain backwards-compatible with version 2 and 3 accessors."
> > > 
> > >  So, theoretically, could one modify the code to selectively disable
> > > silly rename on a client, when it knows it is talking v4 with the
> > > server?
> > > 
> > 
> >  BTW, to clarify, I'm assuming a scenario where the server is
> > configured to talk v4 only, which I suspect should be common, at least
> > when you're relying on v4 kerberos security.
> > 
> 
> Sadly, no...
> 
> The server does generally hold the file open as long as the client has
> the file open. So, you could delete the file while nfsd has it open and
> everything would probably still work.
> 
> Suppose though that the server crashes and reboots. When it comes back
> up, fsck figures out that the file has been unlinked and frees the
> blocks on the disk. Now you can't reclaim the state on the open file.
> 
> We're pretty much stuck with silly-renaming even for v4.

The server could do something like rename the file into a special
directory somewhere that only it had access to, preserving the file
across reboot.  Then at the end of the grace period it would remove any
files in that directory that had not been reclaimed by some client.

The problem would still remain that the *client* wouldn't know that the
server was capable of doing this, so would still be stuck doing
sillyrename on its own just to be sure.

NFSv4.1 adds an open return flag which allows the server to tell the
client that the client doesn't need to do sillyrename; see the
discussion of OPEN4_RESULT_PRESERVE_UNLINKED flag in rfc 5661.

I don't think anyone's looked into implementing that yet; might be a fun
project.

--b.
