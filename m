Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esa-jnhn.mail.uoguelph.ca ([131.104.91.44]:3674 "EHLO
	esa-jnhn.mail.uoguelph.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757722Ab2CSWZe convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 18:25:34 -0400
Date: Mon, 19 Mar 2012 18:25:33 -0400 (EDT)
From: Rick Macklem <rmacklem@uoguelph.ca>
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: linux-nfs@vger.kernel.org, nfsv4@ietf.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Message-ID: <716104306.1267694.1332195933869.JavaMail.root@erie.cs.uoguelph.ca>
In-Reply-To: <4F677E63.90300@rath.org>
Subject: Re: [nfsv4] NFS4 over VPN hangs when connecting > 2 clients
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Nikolaus Rath wrote:
> On 03/19/2012 02:39 PM, J. Bruce Fields wrote:
> > On Mon, Mar 19, 2012 at 02:29:46PM -0400, Chuck Lever wrote:
> >>
> >> On Mar 19, 2012, at 2:27 PM, J. Bruce Fields wrote:
> >>
> >>> On Mon, Mar 19, 2012 at 01:47:14PM -0400, Chuck Lever wrote:
> >>>>
> >>>> On Mar 19, 2012, at 1:36 PM, J. Bruce Fields wrote:
> >>>>> Well, sure, but all I'm proposing here is returning
> >>>>> NFS4ERR_INUSE in the
> >>>>> case where we get setclientid's with the same client-provided
> >>>>> id.
> >>>>> There'd be no change of behavior in the case of multiple clients
> >>>>> sharing
> >>>>> an IP (which is fine, of course).
> >>>>
> >>>> The migration draft proposes that clients use the same
> >>>> nfs_client_id4 string for all of a server's IP addresses. Would a
> >>>> server then be obliged to return NFS4ERR_CLID_IN_USE if a client
> >>>> attempts a SETCLIENTID with the same boot verifier and
> >>>> nfs_client_id4 on more than one IP address for the same server?
> >>>
> >>> That's also not this case, sorry, this time with all the
> >>> conditions:
> >>>
> >>> 	- if the nfs_client_id4 is the same, and
> >>> 	- if the flavor is auth_sys, and
> >>> 	- if the client IP address is different,
> >>> 	- then return NFS4ERR_INUSE.
> >>
> >> This still breaks for multi-homed servers and UCS clients. The
> >> client IP address can be different depending on what server IP
> >> address the client is accessing, but all the other parameters are
> >> the same.
> >
> > OK. So probably there's nothing we can do to help here.
> >
> > As a bandaid maybe a rate-limited log message ("clientid X now in
> > use
> > from IP Y") might help debug these things....
> 
> Since you guys keep Cc'ing me, I'll chime in with a rather naive
> suggestion: if all that's required is a unique id for every client,
> why
> not use the MAC of the first network interface, independent of it
> being
> used for communication with the server?
> 
I think this works fairly well for "real hardware", but I'm not so sure
about clients running in VMs. (I don't really know how the VMs assign
MAC addresses to their fake net interfaces and what uniqueness guarantees
those have. I remember the old freebie VMware client for Windows just
had a config file that assigned the MAC. I bet half the installations
on the planet had the same MAC as the default config file:-)

rick
ps: Also, although it's not very relevant, getting the MAC address of
    the first ethernet interface isn't easy in FreeBSD. I have no idea
    if the same is true of Linux. (I'd also be worried that "first"
    might not be fixed?)

> 
> Best,
> 
> -Nikolaus
> 
> --
> »Time flies like an arrow, fruit flies like a Banana.«
> 
> PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6 02CF A9AD B7F8 AE4E 425C
> _______________________________________________
> nfsv4 mailing list
> nfsv4@ietf.org
> https://www.ietf.org/mailman/listinfo/nfsv4
