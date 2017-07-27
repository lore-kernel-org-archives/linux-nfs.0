Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:37241 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdG0Ldu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jul 2017 07:33:50 -0400
Received: by mail-qt0-f177.google.com with SMTP id 16so21349199qtz.4
        for <linux-nfs@vger.kernel.org>; Thu, 27 Jul 2017 04:33:50 -0700 (PDT)
Message-ID: <1501155226.2767.1.camel@redhat.com>
Subject: Re: [PATCH nfs-utils v2 05/12] getport: recognize "vsock" netid
From: Jeff Layton <jlayton@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>, NeilBrown <neilb@suse.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>
Date: Thu, 27 Jul 2017 07:33:46 -0400
In-Reply-To: <20170727105835.GF10129@stefanha-x1.localdomain>
References: <20170630132120.31578-1-stefanha@redhat.com>
         <20170630132120.31578-6-stefanha@redhat.com>
         <952499A1-FBBA-4FD8-97A6-B0014FA5065D@oracle.com>
         <87wp7lvst9.fsf@notabene.neil.brown.name>
         <87tw2ox4st.fsf@notabene.neil.brown.name>
         <20170725100513.GA5073@stefanha-x1.localdomain>
         <87eft2wjfy.fsf@notabene.neil.brown.name>
         <20170727105835.GF10129@stefanha-x1.localdomain>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-07-27 at 11:58 +0100, Stefan Hajnoczi wrote:
> On Thu, Jul 27, 2017 at 03:13:53PM +1000, NeilBrown wrote:
> > On Tue, Jul 25 2017, Stefan Hajnoczi wrote:
> > > On Fri, Jul 07, 2017 at 02:13:38PM +1000, NeilBrown wrote:
> > > > On Fri, Jul 07 2017, NeilBrown wrote:
> > > > > On Fri, Jun 30 2017, Chuck Lever wrote:
> > > > 
> > > > I don't think the server can filter connections based on which
> > > > interface
> > > > a link-local address came from.  If that was a problem that
> > > > someone
> > > > wanted to be fixed, I'm sure we can fix it.
> > > > 
> > > > If you need to be sure that clients don't fake their IPv6
> > > > address, I'm
> > > > sure netfilter is up to the task.
> > > 
> > > Yes, it's common to prevent spoofing on the host using netfilter
> > > and I
> > > think it wouldn't be a problem.
> > > 
> > > >  . Creates network interfaces on host that must be managed
> > > > 
> > > > What vsock does is effectively create a hidden interface on the
> > > > host that only the
> > > > kernel knows about and so the sysadmin cannot break it.  The
> > > > only
> > > > difference between this and an explicit interface on the host
> > > > is that
> > > > the latter requires a competent sysadmin.
> > > > 
> > > > If you have other reasons for preferring the use of vsock for
> > > > NFS, I'd be
> > > > happy to hear them.  So far I'm not convinced.
> > > 
> > > Before working on AF_VSOCK I originally proposed adding dedicated
> > > network interfaces to guests, similar to what you've suggested,
> > > but
> > > there was resistance for additional reasons that weren't covered
> > > in the
> > > presentation:
> > 
> > I would like to suggest that this is critical information for
> > understanding the design rationale for AF_VSOCK and should be
> > easily
> > found from http://wiki.qemu.org/Features/VirtioVsock
> 
> Thanks, I have updated the wiki.
> 
> > To achieve zero-config, I think link-local addresses are by far the
> > best
> > answer.  To achieve isolation, some targeted filtering seems like
> > the
> > best approach.
> >
> > If you really want traffic between guest and host to go over a
> > vsock,
> > then some sort of packet redirection should be possible.
> 
> The issue we seem to hit with designs using AF_INET and network
> interfaces is that they cannot meet the "it must avoid invasive
> configuration changes, especially inside the guest"
> requirement.  It's
> very hard to autoconfigure in a way that doesn't conflict with the
> user's network configuration inside the guest.
> 
> One thought about solving the interface naming problem: if the
> dedicated
> NIC uses a well-known OUI dedicated for this purpose then udev could
> assign a persistent name (e.g. "virtguestif").  This gets us one step
> closer to non-invasive automatic configuration.

Link-local IPv6 addresses are always present once you bring up an IPv6
interface. You can use them to communicate with other hosts on the same
network segment. It's just not routable. That seems entirely fine here
where you're not dealing with routing anyway.

What I would (naively) envision is a new network interface driver that
presents itself as "hvlo0" or soemthing, much like we do with the
loopback interface. You just need the guest to ensure that it plugs in
that driver and brings up the interface for ipv6.

Then the only issue is discovery of addresses. The HV should be able to
figure that out and present it. Maybe roll up a new nsswitch module
that queries the HV directly somehow? The nice thing there is that you
get name resolution "for free", since it's just plain old IPv6 traffic
at that point.

AF_VSOCK just seems like a very invasive solution to this problem
that's going to add a lot of maintenance burden to a lot of different
code.
-- 
Jeff Layton <jlayton@redhat.com>
