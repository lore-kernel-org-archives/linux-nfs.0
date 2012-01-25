Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42099 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab2AYSzb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 13:55:31 -0500
Date: Wed, 25 Jan 2012 13:55:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120125185529.GJ17873@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
 <20120124230855.GE12426@fieldses.org>
 <20120125064158.4551a012@tlielax.poochiereds.net>
 <20120125131116.GA17873@fieldses.org>
 <20120125083820.637c8362@tlielax.poochiereds.net>
 <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com>
 <20120125171401.GI17873@fieldses.org>
 <D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 12:41:27PM -0500, Chuck Lever wrote:
> If SETCLIENTID returns a unique clientid4 that a client hasn't seen from other servers, the client knows that's a unique server instance which must be recovered separately after a reboot.

Hm, but does it have to do the recovery with that server?

And if so, then how does that fit with failover?

I mean, suppose the whole cluster is rebooted.  From the client's point
of view, its server becomes unresponsive.  So it should probably start
pinging the replicas to see if another one's up.  The first server it
gets a response from won't necessarily be the one it was using before.
What happens next?

--b.
