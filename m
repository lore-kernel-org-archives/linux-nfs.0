Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yb0-f180.google.com ([209.85.213.180]:34526 "EHLO
        mail-yb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756192AbcIFQA4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2016 12:00:56 -0400
Received: by mail-yb0-f180.google.com with SMTP id x93so87266985ybh.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Sep 2016 09:00:55 -0700 (PDT)
Message-ID: <1473177653.13234.22.camel@redhat.com>
Subject: Re: 4.6, 4.7 slow ifs export with more than one client.
From: Jeff Layton <jlayton@redhat.com>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: linux-nfs@vger.kernel.org
Date: Tue, 06 Sep 2016 12:00:53 -0400
In-Reply-To: <05AA5CE8-143C-4CB7-AFF0-36BE495AA328@linuxhacker.ru>
References: <6C329B27-111A-4B16-84F4-7357940EBC01@linuxhacker.ru>
         <1473172215.13234.8.camel@redhat.com>
         <A7375479-E5A6-47FE-915E-8E2B6E5CF012@linuxhacker.ru>
         <1473175124.13234.16.camel@redhat.com>
         <05AA5CE8-143C-4CB7-AFF0-36BE495AA328@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-09-06 at 11:47 -0400, Oleg Drokin wrote:
> On Sep 6, 2016, at 11:18 AM, Jeff Layton wrote:
> 
> > 
> > On Tue, 2016-09-06 at 10:58 -0400, Oleg Drokin wrote:
> > > 
> > > On Sep 6, 2016, at 10:30 AM, Jeff Layton wrote:
> > > 
> > > > 
> > > > 
> > > > On Mon, 2016-09-05 at 00:55 -0400, Oleg Drokin wrote:
> > > > > 
> > > > > 
> > > > > Hello!
> > > > > 
> > > > >    I have a somewhat mysterious problem with my nfs test rig that I suspect is something
> > > > >    stupid I am missing, but I cannot figure it out and would appreciate any help.
> > > > > 
> > > > >    NFS server is Fedora23 with 4.6.7-200.fc23.x86_64 as the kernel.
> > > > >    Clients are a bunch of 4.8-rc5 nodes, nfsroot.
> > > > >    If I only start one of them, all is fine, if I start all 9 or 10, then suddenly all
> > > > >    operations ground to a half (nfs-wise). NFS server side there's very little load.
> > > > > 
> > > > >    I hit this (or something similar) back in June, when testing 4.6-rcs (and the server
> > > > >    was running 4.4.something I believe), and back then after some mucking around
> > > > >    I set:
> > > > > net.core.rmem_default=268435456
> > > > > net.core.wmem_default=268435456
> > > > > net.core.rmem_max=268435456
> > > > > net.core.wmem_max=268435456
> > > > > 
> > > > >    and while no idea why, that helped, so I stopped looking into it completely.
> > > > > 
> > > > >    Now fast forward to now, I am back at the same problem and the workaround above
> > > > >    does not help anymore.
> > > > > 
> > > > >    I also have a bunch of "NFSD: client 192.168.10.191 testing state ID with incorrect client ID"
> > > > >    in my logs (also had in June. Tried to disable nfs 4.2 and 4.1 and that did not
> > > > >    help).
> > > > > 
> > > > >    So anyway I discovered the nfsdcltrack and such and I noticed that whenever
> > > > >    the kernel calls it, it's always with the same hexid of
> > > > >    4c696e7578204e465376342e32206c6f63616c686f7374
> > > > > 
> > > > >    NAturally if I try to list the content of the sqlite file, I get:
> > > > > sqlite> select * from clients;
> > > > > Linux NFSv4.2 localhost|1473049735|1
> > > > > sqlite> select * from clients;
> > > > > Linux NFSv4.2 localhost|1473049736|1
> > > > > sqlite> select * from clients;
> > > > > Linux NFSv4.2 localhost|1473049737|1
> > > > > sqlite> select * from clients;
> > > > > Linux NFSv4.2 localhost|1473049751|1
> > > > > sqlite> select * from clients;
> > > > > Linux NFSv4.2 localhost|1473049752|1
> > > > > sqlite> 
> > > > > 
> > > > 
> > > > Well, not exactly. It sounds like the clients are all using the same
> > > > long-form clientid string. The server sees that and tosses out any
> > > > state that was previously established by the earlier client, because it
> > > > assumes that the client rebooted.
> > > > 
> > > > The easiest way to work around this is to use the nfs4_unique_id nfs.ko
> > > > module parm on the clients to give them each a unique string id. That
> > > > should prevent the collisions.
> > > 
> > > Hm, but it did work ok in the past.
> > > What determines the unique id now by default?
> > > The clients do start with a different ip address for one, so that
> > > seems to make that a much more good proxy for unique id
> > > (or local ip/server ip as is in case of centos7) than whatever local
> > > hostname is at any random point in time during boot
> > > (where it might not be set yet apparently).
> > > 
> > 
> > The v4.1+ clientid is (by default) determined entirely from the
> > hostname.
> > 
> > IP addresses are a poor choice given that they can easily change for
> > clients that have them dynamically assigned. That's the main reason
> > that v4.0 behaves differently here. The big problems there really come
> > into play with NFSv4 migration. See this RFC draft for the gory
> > details:
> > 
> >     https://tools.ietf.org/html/draft-ietf-nfsv4-migration-issues-10
> 
> Duh, so "ip addresses are unreliable, let's use something even less
> reliable". hostname is also dynamic in a bunch of cases, btw.
> Worst of all, there are very many valid cases where nfs might be mounted
> before hostname is set (or do you regard that as a bug in the environment
> and I should just file a ticket in Fedora bugzilla?)
> 
> Looking over the draft, the two cases are:
> what if client reboots, how do we reclaim state ASAP and
> what if there is server migration, but same client.
> 
> The second case is trivial as long as the client id stays constant no matter
> what server you connect to and might be any number of constant identifiers,
> be it random, or not.
> 
> On the other hand the rebooted client is more interesting. Of course there's
> also a lease expiration (that's what we do in Lustre too, if the client dies,
> it'll be expired eventually, but also if we talk to it and it does not reply,
> we kick it out as well, and this has a much shorter timeout, so not as disruptive).
> 
> Cannot some more unique identifier be used by default?
> Say "mac address of the primary interface, whatever that happens to be",
> in that case as long as your client remains on the same physical box
> (and the network card has not changed), you should be fine.
> I guess there are other ways.
> Ideally, kernel would offer an API (might be there is already, but I cannot find it)
> that could be queried for a unique id like that (with inputs from mac addresses,
> various serial numbers identifiable and such).
> 

Shrug...feel free to propose a better scheme for generating unique ids
if you can think of one. Unfortunately, there are always cases when
these mechanisms for getting a persistent+unique id break down.

That's the reason that nfs provides an interface to allow setting a
uniquifier from userland via module param.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
