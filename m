Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52594 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758670Ab0JSNdq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Oct 2010 09:33:46 -0400
Subject: Re: NFS sillyrename side effect
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@redhat.com>,
        =?ISO-8859-1?Q?Cl=E1udio?= Martins <ctpm@ist.utl.pt>,
        Ian Munsie <imunsie@au1.ibm.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Scott Romanowski <romansc@us.ibm.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <4CBD3D4E.5080305@panasas.com>
References: <1287362142-sup-777@au1.ibm.com>
	 <20101018101059.574b715a@corrin.poochiereds.net>
	 <20101018154811.768baeb5.ctpm@ist.utl.pt>
	 <20101018155344.6e50dbb9.ctpm@ist.utl.pt>
	 <20101018110138.5f5001eb@corrin.poochiereds.net>
	 <20101018171015.GB3744@fieldses.org>  <4CBD3D4E.5080305@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Oct 2010 09:32:48 -0400
Message-ID: <1287495168.2969.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-10-19 at 08:40 +0200, Benny Halevy wrote:
> On 2010-10-18 19:10, J. Bruce Fields wrote:
> > On Mon, Oct 18, 2010 at 11:01:38AM -0400, Jeff Layton wrote:
> >> On Mon, 18 Oct 2010 15:53:44 +0100
> >> Cláudio Martins <ctpm@ist.utl.pt> wrote:
> >>
> >>>
> >>> On Mon, 18 Oct 2010 15:48:11 +0100 Cláudio Martins <ctpm@ist.utl.pt> wrote:
> >>>>
> >>>>  Section D2 ends with:
> >>>>
> >>>> "The NFS version 4 protocol is stateful, and could actually support
> >>>> delete-on-last-close. Unfortunately there isn't an easy way to do this
> >>>> and remain backwards-compatible with version 2 and 3 accessors."
> >>>>
> >>>>  So, theoretically, could one modify the code to selectively disable
> >>>> silly rename on a client, when it knows it is talking v4 with the
> >>>> server?
> >>>>
> >>>
> >>>  BTW, to clarify, I'm assuming a scenario where the server is
> >>> configured to talk v4 only, which I suspect should be common, at least
> >>> when you're relying on v4 kerberos security.
> >>>
> >>
> >> Sadly, no...
> >>
> >> The server does generally hold the file open as long as the client has
> >> the file open. So, you could delete the file while nfsd has it open and
> >> everything would probably still work.
> >>
> >> Suppose though that the server crashes and reboots. When it comes back
> >> up, fsck figures out that the file has been unlinked and frees the
> >> blocks on the disk. Now you can't reclaim the state on the open file.
> >>
> >> We're pretty much stuck with silly-renaming even for v4.
> > 
> > The server could do something like rename the file into a special
> > directory somewhere 
> 
> The clients can do something similar too, like sillyrenaming the
> files onto <mountpoint>/.unlinked_while_opened.<client-id>
> Removing this directory when it empties.

This would require access, directory create, and delete permissions for
the directory '<mountpoint>/', which is not always a given.

Besides, what if the server reboots, and my clientid changes?

Trond
