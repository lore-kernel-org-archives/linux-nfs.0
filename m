Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:35645 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752987Ab2DQPNi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 11:13:38 -0400
Date: Tue, 17 Apr 2012 11:14:11 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: linux-nfs@vger.kernel.org, jiri.horky@cesnet.cz
Subject: Re: NFSv4 high availability setups
Message-ID: <20120417111411.334c3d2b@corrin.poochiereds.net>
In-Reply-To: <20120417143448.GU32132@ics.muni.cz>
References: <20120405103124.GV4752@ics.muni.cz>
	<20120405073901.63d1c749@tlielax.poochiereds.net>
	<20120410125552.GC5074@ics.muni.cz>
	<20120410091321.1be1a87e@tlielax.poochiereds.net>
	<20120417143448.GU32132@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 17 Apr 2012 16:34:48 +0200
Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:

> Hi,
> 
> On Tue, Apr 10, 2012 at 09:13:21AM -0400, Jeff Layton wrote:
> > Nope. It'll all work just great...until it doesn't. I don't have any
> > specific failure scenarios, but most of the problems will be issues
> > with state recovery when a server node is restarted.
> > 
> > That may manifest in different ways -- problems reclaiming locks for
> > instance, or even silent data corruption depending on the application.
> 
> would it work if I relax active-active scenario to just active-passive in the
> following way:
> 
> Server A actively exports  /export/A
> Server B actively exports  /export/B
> 
> Server B is passive backup for Server A
> Server A is passive backup for Server B
> 
> would it work to migrate the failed Server B to Server A so that Server A will
> server both /export/A and /export/B?
> 
> There will be a problem with v4recovery dir. Would it be possible just to
> merge v4recovery from Server B to Server A (nfs export would be stopped while
> merging v4recovery).
> 
> It seems that cp -r B/v4recovery/* A/v4recovery/ would do all the things. Am
> I right?
> 
> Do I need to copy recovery state if I delay migration of the failed Server B to
> Server A for 91 secs? I.e., longer than lease expiry time.. Or do I still need
> a record for the client in v4recovery dir in such a case?
> 

That'll still be dangerous. Suppose (for instance) that a client1 lost
communication with server B for a period of time and then it expired
the lease and handed out a lock to client2 that it was holding
previously. client2 modifies the file and drops the lock. At the same
time, client1 has uninterrupted communication with serverA, and holds
state on it.

Eventually, you fail over server B and merge the directories. client1
attempts to renew its lease, but gets back an error and starts
reclaiming things. Now, server B would have denied reclaim of that lock
-- its lease had expired, but in this case it's allowed because you
merged the directory and it client1 held state on serverA. client1
reclaims the lock and thinks that it's held the lock the entire time --
data corruption and other hilarity ensues...

-- 
Jeff Layton <jlayton@redhat.com>
