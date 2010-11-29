Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28265 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755717Ab0K2XkH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 18:40:07 -0500
Subject: RE: NFSv4 behaviour on unknown users
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Spencer Shepler <spencer.shepler@gmail.com>
Cc: Daniel.Muntz@emc.com, spelic@shiftmail.org, linux-nfs@vger.kernel.org
In-Reply-To: <068901cb901d$61395630$23ac0290$@gmail.com>
References: <1291054975.12784.17.camel@heimdal.trondhjem.org>
	 <DE966DA98A4ABE438D726BDF1699CF610437B188C9@MX05A.corp.emc.com>
	 <067101cb9018$d70ba2f0$8522e8d0$@gmail.com>
	 <1291072571.20567.26.camel@heimdal.trondhjem.org>
	 <1291073174.20567.31.camel@heimdal.trondhjem.org>
	 <068901cb901d$61395630$23ac0290$@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Nov 2010 18:40:02 -0500
Message-ID: <1291074002.20567.38.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-29 at 15:30 -0800, Spencer Shepler wrote:
> 
> > -----Original Message-----
> > From: Trond Myklebust [mailto:Trond.Myklebust@netapp.com]
> > Sent: Monday, November 29, 2010 3:26 PM
> > To: Spencer Shepler
> > Cc: Daniel.Muntz@emc.com; spelic@shiftmail.org; linux-nfs@vger.kernel.org
> > Subject: RE: NFSv4 behaviour on unknown users
> > 
> > On Mon, 2010-11-29 at 18:16 -0500, Trond Myklebust wrote:
> > > On Mon, 2010-11-29 at 14:57 -0800, Spencer Shepler wrote:
> > > > Dan,
> > > >
> > > > A change to the NFSv4.0 and NFSv4.1 RFCs is unnecessary.
> > > > What you suggest can be implemented today and still adhere to the
> > > > RFC text.  From RFC3530 (section 4.8) and RFC5661 (section 5.9) the
> > > > following text is quoted:
> > > >
> > > > "  In the case where there is no translation available to the client
> > or
> > > >    server, the attribute value will be constructed without the "@".
> > > >    Therefore, the absence of the @ from the owner or owner_group
> > > >    attribute signifies that no translation was available at the sender
> > > >    and that the receiver of the attribute should not use that string
> > as
> > > >    a basis for translation into its own internal format.  Even though
> > > >    the attribute value cannot be translated, it may still be useful.
> > In
> > > >    the case of a client, the attribute string may be used for local
> > > >    display of ownership.
> > > >
> > > >    To provide a greater degree of compatibility with NFSv3, which
> > > >    identified users and groups by 32-bit unsigned user identifiers and
> > > >    group identifiers, owner and group strings that consist of decimal
> > > >    numeric values with no leading zeros can be given a special
> > > >    interpretation by clients and servers that choose to provide such
> > > >    support.  The receiver may treat such a user or group string as
> > > >    representing the same user as would be represented by an NFSv3 uid
> > or
> > > >    gid having the corresponding numeric value.  A server is not
> > > >    obligated to accept such a string, but may return an
> > NFS4ERR_BADOWNER
> > > >    instead.  To avoid this mechanism being used to subvert user and
> > > >    group translation, so that a client might pass all of the owners
> > and
> > > >    groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
> > > >    error when there is a valid translation for the user or owner
> > > >    designated in this way.  In that case, the client must use the
> > > >    appropriate name@domain string and not the special form for
> > > >    compatibility."
> > > >
> > > >
> > > > I read this that if the implementation or administrator chooses to
> > > > op-out of the user@domain mapping, it may do so and the client and
> > > > server have a method available to them to communicate traditiona
> > > > uid/gid.
> > > >
> > > > So, all that is needed now it seems is some code to provide the
> > > > option to the admin or as you suggest, change the default.
> > > >
> > > > Spencer
> > >
> > > It is way too late to change the default. All known existing NFSv4
> > > servers would spit at you because they have been coded to match the
> > > above normative "SHOULD".
> > >
> > > Without that option, you will also need a mechanism to allow the
> > > client and server to agree on a convention. Otherwise, admins have to
> > > go in and manually set the correct site default on all their clients and
> > servers.
> > 
> > The other problem is that when you use the naked uid or gid you are losing
> > information about which domain the user belongs to.
> > 
> > While that may be fine when you are authenticating using the AUTH_SYS
> > security flavour, it is just plain wrong when you are authenticating using
> > RPCSEC_GSS principals (which is what the NFSv4 spec assumes that you will
> > use).
> 
> Then the administrator will not use that option.
> 
> The use case that was presented did not use Kerberos (at least in my quick reading).
> 
> I agree that users that use Kerberos will be unhappy and that they should
> use something that maps more in align with their Kerberos realms but that
> is not the pain point under discussion.  A variation of the id mapping work
> under discussion by Andy would/could address Kerberos and other deployment
> scenarios.  But for the original "works for NFSv3 and doesn't for NFSv4" crowd
> something simple will suffice and they will be happy and stop bitching
> about this and move onto the next thing that pisses them off. :-)

It would not be backwards compatible: the linux server will currently
reject any uid/gid usage by the client.

That said, I can imagine that for 'sec=sys', we might be able to change
the client to use the uid/gid format by default, and then change back to
doing name@domain upon receiving the first NFS4ERR_BADOWNER error from
the server.
It the server changes to match this, then that might suffice solve the
current problem that we have with doing nfsroot on NFSv4...

Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

