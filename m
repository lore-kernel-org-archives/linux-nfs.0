Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:31298 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430Ab2AYU3p convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 15:29:45 -0500
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120125185529.GJ17873@fieldses.org>
Date: Wed, 25 Jan 2012 15:29:34 -0500
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <7D6EA28C-26F1-46A3-B1C5-6BC6F6AE713D@oracle.com>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com> <20120124230855.GE12426@fieldses.org> <20120125064158.4551a012@tlielax.poochiereds.net> <20120125131116.GA17873@fieldses.org> <20120125083820.637c8362@tlielax.poochiereds.net> <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com> <20120125171401.GI17873@fieldses.org> <D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com> <20120125185529.GJ17873@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 25, 2012, at 1:55 PM, J. Bruce Fields wrote:

> On Wed, Jan 25, 2012 at 12:41:27PM -0500, Chuck Lever wrote:
>> If SETCLIENTID returns a unique clientid4 that a client hasn't seen from other servers, the client knows that's a unique server instance which must be recovered separately after a reboot.
> 
> Hm, but does it have to do the recovery with that server?

If a client has a lease and open state on that server, it should do recovery if the server reboots.

> And if so, then how does that fit with failover?

We were supposed to discuss that with Bill and Piyush.  Maybe we can bring it up again at Connectathon.  But my assumption is that fail over is supposed to look like a server reboot.  The question is what clients does the server allow to recover, and which does it force to start fresh?  Shouldn't it be enough for a server to remember nfs_client_id4 strings?

> I mean, suppose the whole cluster is rebooted.  From the client's point
> of view, its server becomes unresponsive.  So it should probably start
> pinging the replicas to see if another one's up.  The first server it
> gets a response from won't necessarily be the one it was using before.
> What happens next?

Again, it depends on whether your clustering implementation shares state among all servers in the cluster.

Sharing state across a cluster seems like a difficult implementation choice.  For simplicity I think each server in a cluster should manage its own leases.  NFSv4.0 replication is generally for read-only datasets anyway.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




