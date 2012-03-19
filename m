Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42651 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754527Ab2CSRg6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Mar 2012 13:36:58 -0400
Date: Mon, 19 Mar 2012 13:36:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rick Macklem <rmacklem@uoguelph.ca>
Cc: Nikolaus Rath <Nikolaus@rath.org>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
Message-ID: <20120319173656.GA23670@fieldses.org>
References: <1085412836.1228438.1332175460830.JavaMail.root@erie.cs.uoguelph.ca>
 <1802632483.1230802.1332176807484.JavaMail.root@erie.cs.uoguelph.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1802632483.1230802.1332176807484.JavaMail.root@erie.cs.uoguelph.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 19, 2012 at 01:06:47PM -0400, Rick Macklem wrote:
> I wrote:
> > J. Bruce Fields wrote:
> > > On Mon, Mar 12, 2012 at 05:27:08PM -0400, J. Bruce Fields wrote:
> > > > On Mon, Mar 12, 2012 at 05:14:16PM -0400, Chuck Lever wrote:
> > > > > IMO, the server should do a comparison of the nfs_client_id4
> > > > > strings,
> > > > > and nothing else.
> > > >
> > > > We're supposed to return CLID_INUSE when we see a setclientid from
> > > > a
> > > > "different" client using the same string, to keep clients from
> > > > doing
> > > > mischief with other clients' state (either maliciously or, as in
> > > > this
> > > > case, accidentally).
> > > >
> > > > "Different" here is defined as "not having the same principal". I
> > > > know
> > > > what that means in the krb5 case, but I'm less certain in the
> > > > auth_sys
> > > > case.
> > >
> > > Cc'ing the ietf list. Is it reasonable for a server to expect
> > > setclientid's to come from the same client IP address at least in
> > > the
> > > auth_sys case, or could that break multi-homed clients?
> > >
> > I think that even a dhcp lease renewal might result in a different
> > client
> > IP, if the client has been partitioned from the dhcp server for a
> > while.

Yeah, but by that point the client's v4 lease is probably expired anyway
so the client's not likely to be bothered by the NFS4ERR_INUSE.

> > I'm not convinced that different client IP# implies different client.
> > (Even "same ip# implies same client" might not be true, if the dhcp
> > server assigned the IP# to another machine while the client was
> > partitioned
> > from the dhcp server, I think? I haven't looked at current dhcp
> > implementations, but it seems conceivable to me.)
> > 
> Oh, and what about the case of 2 clients that are sitting behind
> the same NAT gateway? (I think they'd both be seen as having the
> client host ip# of the gateway, but with different TCP connections
> on different client port#s.)

Well, sure, but all I'm proposing here is returning NFS4ERR_INUSE in the
case where we get setclientid's with the same client-provided id.
There'd be no change of behavior in the case of multiple clients sharing
an IP (which is fine, of course).

> > For AUTH_SYS, all the FreeBSD server does is expect the same uid#.

Yeah, but that's probably usually the same between clients.

--b.
