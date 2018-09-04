Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:37118 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726327AbeIDQgu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Sep 2018 12:36:50 -0400
Message-ID: <c78c32d78e2d45665336a5a441ee79546858b729.camel@kernel.org>
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
From: Jeff Layton <jlayton@kernel.org>
To: Harald Dunkel <harald.dunkel@aixigo.de>, linux-nfs@vger.kernel.org
Date: Tue, 04 Sep 2018 08:11:55 -0400
In-Reply-To: <cf2e08fb-7130-d40f-fa93-bf805c87b770@aixigo.de>
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
         <b4c125d6-be59-6953-bfa7-8ada6f8daa01@aixigo.de>
         <30d4e07de5d976756857db77ddb17582897ae2bf.camel@kernel.org>
         <a5a072db-8624-3f52-867e-c7a612df811f@aixigo.de>
         <4aa0284e9f2d4b7994aa976926fd1a84493ee228.camel@kernel.org>
         <cf2e08fb-7130-d40f-fa93-bf805c87b770@aixigo.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2018-09-04 at 09:31 +0200, Harald Dunkel wrote:
> Hi Jeff,
> 
> On 9/3/18 11:32 AM, Jeff Layton wrote:
> > 
> > Yes, typically a server reboot will cause the client to reclaim its
> > state. If the server isn't restarting then you probably have a situation
> > where the client and server have gotten out of sync in some fashion, the
> > client is realizing it and attempting to reclaim its state.
> > 
> > One thing that could (potentially) cause this is a nfs4_unique_id
> > collision. You might want to survey your clients and ensure that there
> > aren't any.
> > 
> 
> /sys/module/nfs/parameters/nfs4_unique_id tells me that the default
> is an empty string. Thats hard to believe. I had expected the default
> is derived from the mac address of eth0 or something like this. ???
> 
> All explicitly defined nfs4_unique_id are unique, I checked (on the
> Linux hosts). il06 (the NFS client here) and 4 other ancient servers
> *were* running with the default "unique" id. My fault.
> 

In general, the long-form clientid needs to be unique for each client.

nfs4_unique_id is just a uniquifier for the long-form client ID string.
If it's blank then it'll just use the current nodename (hostname)
without one. If you have uniquifier collisions among hosts with
different hostnames, then you'll still get different strings. See
nfs4_init_uniform_client_string() in the kernel sources for details.

> > > Would you recommend to stick with NFS 4(.0) or NFS 3, avoiding the
> > > new code in NFS 4.{1,2}? Which NFS version in 4.9 or another LTS
> > > kernel suits best for production use?
> > > 
> > 
> > v4.1+ are fine (in general) for production, but there are always bugs.
> > 
> 
> How do NFS version numbers on client and Linux server affect each
> other? AIX 7.1 (just as an example) supports just "nfs" and "nfs4",
> not "nfs4.1" or "nfs4.2". Will the AIX clients benefit from the bug
> fixes included in Linux' nfs 4.1+?
> 

I'm not sure -- it really depends on whether AIX supports v4.1+.

In general, the server will "advertise" what versions it supports and
the Linux client will negotiate to the highest supported version. I'm
not sure what other clients will do.

-- 
Jeff Layton <jlayton@kernel.org>
