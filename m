Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64207 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754486Ab0K2X0S convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 18:26:18 -0500
Subject: RE: NFSv4 behaviour on unknown users
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Spencer Shepler <spencer.shepler@gmail.com>
Cc: Daniel.Muntz@emc.com, spelic@shiftmail.org, linux-nfs@vger.kernel.org
In-Reply-To: <1291072571.20567.26.camel@heimdal.trondhjem.org>
References: <1291054975.12784.17.camel@heimdal.trondhjem.org>
	 <DE966DA98A4ABE438D726BDF1699CF610437B188C9@MX05A.corp.emc.com>
	 <067101cb9018$d70ba2f0$8522e8d0$@gmail.com>
	 <1291072571.20567.26.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 29 Nov 2010 18:26:14 -0500
Message-ID: <1291073174.20567.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-11-29 at 18:16 -0500, Trond Myklebust wrote:
> On Mon, 2010-11-29 at 14:57 -0800, Spencer Shepler wrote:
> > Dan,
> > 
> > A change to the NFSv4.0 and NFSv4.1 RFCs is unnecessary.
> > What you suggest can be implemented today and still adhere
> > to the RFC text.  From RFC3530 (section 4.8) and RFC5661 (section 5.9)
> > the following text is quoted:
> > 
> > "  In the case where there is no translation available to the client or
> >    server, the attribute value will be constructed without the "@".
> >    Therefore, the absence of the @ from the owner or owner_group
> >    attribute signifies that no translation was available at the sender
> >    and that the receiver of the attribute should not use that string as
> >    a basis for translation into its own internal format.  Even though
> >    the attribute value cannot be translated, it may still be useful.  In
> >    the case of a client, the attribute string may be used for local
> >    display of ownership.
> > 
> >    To provide a greater degree of compatibility with NFSv3, which
> >    identified users and groups by 32-bit unsigned user identifiers and
> >    group identifiers, owner and group strings that consist of decimal
> >    numeric values with no leading zeros can be given a special
> >    interpretation by clients and servers that choose to provide such
> >    support.  The receiver may treat such a user or group string as
> >    representing the same user as would be represented by an NFSv3 uid or
> >    gid having the corresponding numeric value.  A server is not
> >    obligated to accept such a string, but may return an NFS4ERR_BADOWNER
> >    instead.  To avoid this mechanism being used to subvert user and
> >    group translation, so that a client might pass all of the owners and
> >    groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
> >    error when there is a valid translation for the user or owner
> >    designated in this way.  In that case, the client must use the
> >    appropriate name@domain string and not the special form for
> >    compatibility."
> > 
> > 
> > I read this that if the implementation or administrator chooses
> > to op-out of the user@domain mapping, it may do so and the client
> > and server have a method available to them to communicate traditiona
> > uid/gid.
> > 
> > So, all that is needed now it seems is some code to provide the
> > option to the admin or as you suggest, change the default.
> > 
> > Spencer
> 
> It is way too late to change the default. All known existing NFSv4
> servers would spit at you because they have been coded to match the
> above normative "SHOULD".
> 
> Without that option, you will also need a mechanism to allow the client
> and server to agree on a convention. Otherwise, admins have to go in and
> manually set the correct site default on all their clients and servers.

The other problem is that when you use the naked uid or gid you are
losing information about which domain the user belongs to.

While that may be fine when you are authenticating using the AUTH_SYS
security flavour, it is just plain wrong when you are authenticating
using RPCSEC_GSS principals (which is what the NFSv4 spec assumes that
you will use).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

