Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:47310 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758122Ab0HQSUz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 14:20:55 -0400
Date: Tue, 17 Aug 2010 14:18:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <tdh@excfb.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        Neil Brown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com,
        linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100817181842.GD23176@fieldses.org>
References: <20100803222337.GA9752@fieldses.org>
 <1280874675.14520.23.camel@heimdal.trondhjem.org>
 <20100803224245.GB9752@fieldses.org>
 <1280887336.24669.23.camel@heimdal.trondhjem.org>
 <20100805153421.GD27141@fieldses.org>
 <20100812092232.344314b2@notabene>
 <4C6559FA.5070809@RedHat.com>
 <20100813163156.GA16863@fieldses.org>
 <1CE074A1-2371-40E5-B0E5-F80474B02FA2@oracle.com>
 <4C6ACAE1.6060100@excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C6ACAE1.6060100@excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 12:46:09PM -0500, Tom Haynes wrote:
> Chuck Lever wrote:
> >On Aug 13, 2010, at 12:31 PM, J. Bruce Fields wrote:
> >>There are four cases where translation can be done:
> >>
> >>	Sending id from server to client (ls, stat, getacl):
> >>		1. server uid -> string
> >>		2. string -> client uid
> >>	Sending id from client to server (chown, setacl):
> >>		3. client uid -> string
> >>		4. string -> client uid
> >>
> >>Cases 1 and 2 are uncontroversial.  Definitely map ascii-fied integers
> >>in both of those cases.
> >>
> >>Case 4 violates the SHOULD on page 47.  Which would make case 3 useless
> >>if all servers respect that SHOULD.  I think we should ignore the SHOULD
> >>and implement 3 and 4 too, but Trond may not agree.
> >
> 
> So how would that happen?

What's the antecedent to "that"?

> If we send "2525" and we can locally map uid 2525 to 'bfields", does
> that mean the client is
> attempting to subvert the normal process?

I don't understand what you mean by "subvert the normal process", nor
what you see as the threat here.

> Or do we have to send uid 2525 to our id mapper to see if a reverse
> mapping applies?

Checking for a reverse mapping doesn't sound like a good idea to me.

> What if there exists a thud@remote with that uid, but the mapping
> was really bfields@crimson?

In the case of a user upgrading from NFSv3 to NFSv4, that's the behavior
they've always had, so presumably they can live with it.  I'd prefer to
avoid situations where something that previously worked over v3 fails
when you upgrade the protocol version.

I assume that most users arrive at NFSv4 by an upgrade from a previous
version of NFS.

So my priorities would be 1) to ensure the NFSv3->NFSv4 upgrade goes
smoothly, then 2) to make it easy for users to switch from ids to
strings, rather than forcing both at once.

--b.
