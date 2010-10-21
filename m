Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7689 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756686Ab0JUS2s convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 14:28:48 -0400
Subject: Re: NFS sillyrename side effect
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        =?ISO-8859-1?Q?Cl=E1udio?= Martins <ctpm@ist.utl.pt>,
        Ian Munsie <imunsie@au1.ibm.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4CC07D54.7070204@panasas.com>
References: <1287362142-sup-777@au1.ibm.com>
	 <20101018101059.574b715a@corrin.poochiereds.net>
	 <20101018154811.768baeb5.ctpm@ist.utl.pt>
	 <20101018155344.6e50dbb9.ctpm@ist.utl.pt>
	 <20101018110138.5f5001eb@corrin.poochiereds.net>
	 <20101018171015.GB3744@fieldses.org>  <4CBD3D4E.5080305@panasas.com>
	 <1287495168.2969.9.camel@heimdal.trondhjem.org>
	 <4CC07D54.7070204@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Oct 2010 14:28:23 -0400
Message-ID: <1287685703.9144.60.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-10-21 at 19:50 +0200, Benny Halevy wrote:
> On 2010-10-19 15:32, Trond Myklebust wrote:
> > On Tue, 2010-10-19 at 08:40 +0200, Benny Halevy wrote:
> >> The clients can do something similar too, like sillyrenaming the
> >> files onto <mountpoint>/.unlinked_while_opened.<client-id>
> >> Removing this directory when it empties.
> > 
> > This would require access, directory create, and delete permissions for
> > the directory '<mountpoint>/', which is not always a given.
> 
> Correct. But that's pretty easy to probe :)

Yup, but you'd then need to handle both cases in order to avoid
regressions.

You'd also have to deal with more complex locking: avoiding deadlocks
when creating mountpoint/.unlinked_while_open.<clientid> while still
holding the directory mutex for the unlink(). That basically requires
you to take mutexes in the opposite order to that required for a
cross-directory rename.

IOW: is it really worth the effort?

Note also that userland can do exactly the same thing. You are basically
proposing to do the whole 'trashcan' concept in kernel space...

> > 
> > Besides, what if the server reboots, and my clientid changes?
> 
> By <client-id> I meant a unique identifier for the client, not necessarily
> the nfsv4.x clientid.  The client could just as well use its ip address
> (to help admins deal with the aftermath in case the client goes away) and its
> boot time, or even a random string.

Trond
