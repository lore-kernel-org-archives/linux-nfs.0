Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:1315 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757719Ab2CSWbd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 18:31:33 -0400
Date: Mon, 19 Mar 2012 18:31:32 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Nikolaus Rath <Nikolaus@rath.org>, linux-nfs@vger.kernel.org,
        nfsv4@ietf.org, "J. Bruce Fields" <bfields@fieldses.org>
Message-ID: <1346589966.1267949.1332196292754.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <126867CF-7CAA-4E3D-A9D6-2A5FE30A7DB4@oracle.com>
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Mar 19, 2012, at 1:36 PM, J. Bruce Fields wrote:
> 
> > On Mon, Mar 19, 2012 at 01:06:47PM -0400, Rick Macklem wrote:
> >> I wrote:
> >>> J. Bruce Fields wrote:
> >>>> On Mon, Mar 12, 2012 at 05:27:08PM -0400, J. Bruce Fields wrote:
> >>>>> On Mon, Mar 12, 2012 at 05:14:16PM -0400, Chuck Lever wrote:
> >>>>>> IMO, the server should do a comparison of the nfs_client_id4
> >>>>>> strings,
> >>>>>> and nothing else.
> >>>>>
> >>>>> We're supposed to return CLID_INUSE when we see a setclientid
> >>>>> from
> >>>>> a
> >>>>> "different" client using the same string, to keep clients from
> >>>>> doing
> >>>>> mischief with other clients' state (either maliciously or, as in
> >>>>> this
> >>>>> case, accidentally).
> >>>>>
> >>>>> "Different" here is defined as "not having the same principal".
> >>>>> I
> >>>>> know
> >>>>> what that means in the krb5 case, but I'm less certain in the
> >>>>> auth_sys
> >>>>> case.
> >>>>
> >>>> Cc'ing the ietf list. Is it reasonable for a server to expect
> >>>> setclientid's to come from the same client IP address at least in
> >>>> the
> >>>> auth_sys case, or could that break multi-homed clients?
> >>>>
> >>> I think that even a dhcp lease renewal might result in a different
> >>> client
> >>> IP, if the client has been partitioned from the dhcp server for a
> >>> while.
> >
> > Yeah, but by that point the client's v4 lease is probably expired
> > anyway
> > so the client's not likely to be bothered by the NFS4ERR_INUSE.
> >
> >>> I'm not convinced that different client IP# implies different
> >>> client.
> >>> (Even "same ip# implies same client" might not be true, if the
> >>> dhcp
> >>> server assigned the IP# to another machine while the client was
> >>> partitioned
> >>> from the dhcp server, I think? I haven't looked at current dhcp
> >>> implementations, but it seems conceivable to me.)
> >>>
> >> Oh, and what about the case of 2 clients that are sitting behind
> >> the same NAT gateway? (I think they'd both be seen as having the
> >> client host ip# of the gateway, but with different TCP connections
> >> on different client port#s.)
> >
> > Well, sure, but all I'm proposing here is returning NFS4ERR_INUSE in
> > the
> > case where we get setclientid's with the same client-provided id.
> > There'd be no change of behavior in the case of multiple clients
> > sharing
> > an IP (which is fine, of course).
> 
> The migration draft proposes that clients use the same nfs_client_id4
> string for all of a server's IP addresses. Would a server then be
> obliged to return NFS4ERR_CLID_IN_USE if a client attempts a
> SETCLIENTID with the same boot verifier and nfs_client_id4 on more
> than one IP address for the same server?
> 
> IMO the server should not try to sort this situation out.
> 
> >>> For AUTH_SYS, all the FreeBSD server does is expect the same uid#.
> >
> > Yeah, but that's probably usually the same between clients.
> 
0 maybe;-) But that's all the RFC says, so I think all a server can
do is hope the clients do a good just of generating unique
nfs_client_id4 strings?

rick
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
