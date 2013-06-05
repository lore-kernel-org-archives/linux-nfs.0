Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:37456 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755308Ab3FEPOK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jun 2013 11:14:10 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "E.G. Keizer" <E.G.Keizer@vu.nl>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential
 issue.
Date: Wed, 5 Jun 2013 15:14:04 +0000
Message-ID: <1370445238.21544.35.camel@leira.trondhjem.org>
References: <51AF459A.1040609@vu.nl>
	 <1370442331.21544.16.camel@leira.trondhjem.org> <51AF4FCB.9000503@vu.nl>
In-Reply-To: <51AF4FCB.9000503@vu.nl>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-06-05 at 16:48 +0200, E.G. Keizer wrote:
> 
> On 05/06/2013 16:25, Myklebust, Trond wrote:
> > On Wed, 2013-06-05 at 16:05 +0200, E.G. Keizer wrote:
> >> First I would like to wholeheartedly support Neil Brown's comment. We at the
> >> Vrije Universiteit in Amsterdam (NL) also have the situation where the Kerberos
> >> administrator does not hand out machine credentials. A lot of Linux users from
> >> the Faculty of Sciences depend on the functionality that lets them access
> >> the NFS file servers with only their user credentials.
> > 
> > They should still be able to do that, but in that case, the state
> > management will have to default to AUTH_SYS to set up the lease, which
> > means that someone else can spoof requests to cancel the lease or change
> > the callback channel parameters.
> We would probably accept that. But can you enlighten me as to why AUTH_SYS is better
> then krb5 (no i, no p)?

I don't understand. If you are not handing out machine creds, then how
can RPCSEC_GSS/krb work where RPCSEC_GSS/krb5i did not?

> >> Secondly I would like to make a remark on basing client id's on the system's kerberos principal's name.
> >> That same faculty, in the times it had its own IT department, used an identical keytab for
> >> all Linux workstations, using the principal names "[nfs|root|host]/workstation@FEW.VU.NL".
> >> I understand this would lead to severe problems when the client id (co_ownerid) is based
> >> solely in the systems root principal name.
> > 
> > How so? The only problem should be that any one of those machines can go
> > and cancel or change the lease of any other. That's a compromise that
> > you decided upon when you decided to use one keytab for all of them.
> Mmm, not at the time we made the decision. But I just mentioned that as an example
> of the problems one can meet when deciding on the implementation of client id.
> The same problem, but on a smaller scale, occurs when the client id is based
> on the system principal and two or more systems use the same user principal as system
> principal.

The only thing that has changed is that if you use the 'migration' mount
option, then the clientid uses the hostname as part of the long form
client id. Otherwise, it uses the ip-address as it did before.

The long form client id is not, and has never been 'based' on a system
principal. It is _authenticated_ by a system principal. All that has
changed is that we've divorced the authentication mechanism from the
mountpoint authentication. We did so in order to avoid the problems that
otherwise arise when mounting several volumes with different
authentication mechanisms from the same server.

> >> It seems to me that the issues about the client id look like a bag of worms. I've seen that the
> >> newest standard `requires' integrity protection for client id exchanges. I doubt
> >> that that will help when the source code of the NFS client is known and
> >> the client id is guessable.
> > 
> > What is the attack and how would it compromise security on the clients
> > that you care about?
> I am personally not that worried about this issue on our environment. But others seem to
> be in their environment. Otherwise the integrity requirement would not have ended up in
> the NFSv4 RFC. As fas as I understand the danger with a man-in-the-middle attack is that the attacker
> can see my client id and thus cancel my lease. When the man-in-the-middle can guess my
> client id he can still invalidate my lease even when i'am using krb5i.

According to the NFSv4 spec, your lease will be authenticated by the
principal + security mechanism. The attacker cannot cancel or modify
that lease without authenticating using the same principal and same
krb5i security mechanism.

I agree that adding krb5p as an option might be a good idea in order to
protect the results of the SETCLIENTID operation; particularly so when
all the other NFS related operations to the server are using krb5p.
The problem is that I know of several servers that currently support
krb5i but not krb5p, and so we'd have to do this too with care until
those servers are spec-compliant.

> >>  The wisest thing might be to offer different options
> >> and let the administrators pick the one they like best?
> > 
> > We have two options available to you: auth_sys or RPCSEC_GSS w/krb5i.
> I meant different options for choosing the client id.
> 
> 
> Regards,
> 
> Ed Keizer
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
