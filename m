Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56524 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759985Ab0HQSva (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 14:51:30 -0400
Date: Tue, 17 Aug 2010 14:49:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Tom Haynes <tdh@excfb.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <SteveD@redhat.com>,
        Neil Brown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jim Rees <rees@umich.edu>, Daniel.Muntz@emc.com,
        linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100817184910.GB26609@fieldses.org>
References: <20100803224245.GB9752@fieldses.org>
 <1280887336.24669.23.camel@heimdal.trondhjem.org>
 <20100805153421.GD27141@fieldses.org>
 <20100812092232.344314b2@notabene>
 <4C6559FA.5070809@RedHat.com>
 <20100813163156.GA16863@fieldses.org>
 <1CE074A1-2371-40E5-B0E5-F80474B02FA2@oracle.com>
 <4C6ACAE1.6060100@excfb.com>
 <20100817181842.GD23176@fieldses.org>
 <4C6AD861.4010506@excfb.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C6AD861.4010506@excfb.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 17, 2010 at 01:43:45PM -0500, Tom Haynes wrote:
> J. Bruce Fields wrote:
> >On Tue, Aug 17, 2010 at 12:46:09PM -0500, Tom Haynes wrote:
> >>Chuck Lever wrote:
> >>>On Aug 13, 2010, at 12:31 PM, J. Bruce Fields wrote:
> >>>>There are four cases where translation can be done:
> >>>>
> >>>>	Sending id from server to client (ls, stat, getacl):
> >>>>		1. server uid -> string
> >>>>		2. string -> client uid
> >>>>	Sending id from client to server (chown, setacl):
> >>>>		3. client uid -> string
> >>>>		4. string -> client uid
> >>>>
> >>>>Cases 1 and 2 are uncontroversial.  Definitely map ascii-fied integers
> >>>>in both of those cases.
> >>>>
> >>>>Case 4 violates the SHOULD on page 47.  Which would make case 3 useless
> >>>>if all servers respect that SHOULD.  I think we should ignore the SHOULD
> >>>>and implement 3 and 4 too, but Trond may not agree.
> >>So how would that happen?
> >
> >What's the antecedent to "that"?
> >
> 
> The SHOULD you quote:
> 
>   To avoid this mechanism being used to subvert user and
>   group translation, so that a client might pass all of the owners and
>   groups in numeric form, a server SHOULD return an NFS4ERR_BADOWNER
>   error when there is a valid translation for the user or owner
>   designated in this way.  In that case, the client must use the
>   appropriate name@domain string and not the special form for
>   compatibility.
> 
> 
> 
> >>If we send "2525" and we can locally map uid 2525 to 'bfields", does
> >>that mean the client is
> >>attempting to subvert the normal process?
> >
> >I don't understand what you mean by "subvert the normal process", nor
> >what you see as the threat here.
> 
> How do you detect the SHOULD?

I'm suggesting not trying to detect it.

I'm not convinced the SHOULD is a good idea, and I think it would be
acceptable, for backwards-compaibility reasons, for a client to "pass
all owners and groups in numeric form".

> >>Or do we have to send uid 2525 to our id mapper to see if a reverse
> >>mapping applies?
> >
> >Checking for a reverse mapping doesn't sound like a good idea to me.
> >
> 
> No, it doesn't. My point is that the SHOULD is hard to enforce. How
> does the server
> determine that there is a "valid translation"?

Agreed.

> >>What if there exists a thud@remote with that uid, but the mapping
> >>was really bfields@crimson?
> >
> >In the case of a user upgrading from NFSv3 to NFSv4, that's the behavior
> >they've always had, so presumably they can live with it.  I'd prefer to
> >avoid situations where something that previously worked over v3 fails
> >when you upgrade the protocol version.
> >
> >I assume that most users arrive at NFSv4 by an upgrade from a previous
> >version of NFS.
> >
> >So my priorities would be 1) to ensure the NFSv3->NFSv4 upgrade goes
> >smoothly, then 2) to make it easy for users to switch from ids to
> >strings, rather than forcing both at once.
> >
> 
> I'd say that problem breaks down to being able to correctly
> configure your id domain or to
> allowing a server which is not connected to NIS/LDAP to be able to
> accept random users.
> With NFSv3, a server will happily serve up data in these situations.
> 
> While various ways pop to mind to hack this up, why not bring it up
> to the working group
> and get consensus? Perhaps whomever struck down Jim Rees will recall
> why it is such
> a bad idea and convince us all to stay away from it. Or perhaps
> after years of enduring
> customers who can't do the above, they will capitulate.

OK.

--b.
