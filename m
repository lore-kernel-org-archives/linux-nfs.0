Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754544AbbFCPvp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2015 11:51:45 -0400
Date: Wed, 3 Jun 2015 11:51:43 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
 BAD_STATEID
In-Reply-To: <CAN-5tyEGq0XNh8hE+3XsD0XG_4XGkeW1cyZvcw==dNTXgXTaAQ@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1506031149180.70615@dhcp-132.nfsv4bat.org>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com> <alpine.OSX.2.19.9992.1505290942250.65323@planck.local> <CAN-5tyE2wepUkuBO=sWwkBpr+jfQzh1+c_QbNykLk=wy3A77UQ@mail.gmail.com>
 <CAN-5tyEGq0XNh8hE+3XsD0XG_4XGkeW1cyZvcw==dNTXgXTaAQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 29 May 2015, Olga Kornievskaia wrote:

> I meant to say 3.10.0-229. Mixing my RHEL6 and RHEL7 prefixes...
>
> On Fri, May 29, 2015 at 12:51 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> > On Fri, May 29, 2015 at 9:44 AM, Benjamin Coddington
> > <bcodding@redhat.com> wrote:
> >> On Thu, 7 May 2015, Olga Kornievskaia wrote:
> >>
> >>> Hi folks,
> >>>
> >>> Problem:
> >>> The upstream nfs4.0 client has problem where it will go into an
> >>> infinite loop of re-sending an OPEN when it's trying to recover from
> >>> receiving a BAD_STATEID error on an IO operation such READ or WRITE.
> >>>
> >>> How to easily reproduce (by using fault injection):
> >>> 1. Do nfs4.0 mount to a server.
> >>> 2. Open a file such that the server gives you a write delegation.
> >>> 3. Do a write. Have a server return a BAD_STATEID. One way to do so is
> >>> by using a python proxy, nfs4proxy, and inject BAD_STATEID error on
> >>> WRITE.
> >>> 4. And off it goes with the loop.
> >>
> >> Hi Olga,
> >>
> >> I've been trying to reproduce it, and I'm frustratingly unable.  It sounds
> >> fairly easy to produce..  What version of the client produces this?
> >>
> >
> > Hi Ben,
> >
> > Problem exists in the upstream kernels as well but we noticed the
> > problem on RHEL7.1 distro (RedHat's 2.6.32-229.el7 kernel I think).

I've now been able to reproduce this upstream, and 7.1.. and just today on a
6.7 client.  The 6.7 client seems to self-limit the OPEN storm to around 7k
OPENs..  That's interesting enough to look into further..

Taking this issue to the BZs for now, just wanted to let the list know that
we see this now, too.

Ben
