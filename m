Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-annu.mail.uoguelph.ca ([131.104.91.36]:40362 "EHLO
	esa-annu.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758422Ab2CSRGs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 13:06:48 -0400
Date: Mon, 19 Mar 2012 13:06:47 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Nikolaus Rath <Nikolaus@rath.org>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
Message-ID: <1802632483.1230802.1332176807484.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <1085412836.1228438.1332175460830.JavaMail.root@erie.cs.uoguelph.ca>
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I wrote:
> J. Bruce Fields wrote:
> > On Mon, Mar 12, 2012 at 05:27:08PM -0400, J. Bruce Fields wrote:
> > > On Mon, Mar 12, 2012 at 05:14:16PM -0400, Chuck Lever wrote:
> > > > IMO, the server should do a comparison of the nfs_client_id4
> > > > strings,
> > > > and nothing else.
> > >
> > > We're supposed to return CLID_INUSE when we see a setclientid from
> > > a
> > > "different" client using the same string, to keep clients from
> > > doing
> > > mischief with other clients' state (either maliciously or, as in
> > > this
> > > case, accidentally).
> > >
> > > "Different" here is defined as "not having the same principal". I
> > > know
> > > what that means in the krb5 case, but I'm less certain in the
> > > auth_sys
> > > case.
> >
> > Cc'ing the ietf list. Is it reasonable for a server to expect
> > setclientid's to come from the same client IP address at least in
> > the
> > auth_sys case, or could that break multi-homed clients?
> >
> I think that even a dhcp lease renewal might result in a different
> client
> IP, if the client has been partitioned from the dhcp server for a
> while.
> 
> I'm not convinced that different client IP# implies different client.
> (Even "same ip# implies same client" might not be true, if the dhcp
> server assigned the IP# to another machine while the client was
> partitioned
> from the dhcp server, I think? I haven't looked at current dhcp
> implementations, but it seems conceivable to me.)
> 
Oh, and what about the case of 2 clients that are sitting behind
the same NAT gateway? (I think they'd both be seen as having the
client host ip# of the gateway, but with different TCP connections
on different client port#s.)

> For AUTH_SYS, all the FreeBSD server does is expect the same uid#.
> 
> rick
> > At least in the auth_sys case IP addresses are one of the only
> > things
> > we
> > have left to go on when the client's identifier-generation is messed
> > up
> > (not that difficult).
> >
> > --b.
> > _______________________________________________
> > nfsv4 mailing list
> > nfsv4@ietf.org
> > https://www.ietf.org/mailman/listinfo/nfsv4
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
