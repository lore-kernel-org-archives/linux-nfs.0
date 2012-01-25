Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751120Ab2AYVZz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 16:25:55 -0500
Date: Wed, 25 Jan 2012 16:25:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120125212553.GA22216@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
 <20120124230855.GE12426@fieldses.org>
 <20120125064158.4551a012@tlielax.poochiereds.net>
 <20120125131116.GA17873@fieldses.org>
 <20120125083820.637c8362@tlielax.poochiereds.net>
 <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com>
 <20120125171401.GI17873@fieldses.org>
 <D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com>
 <20120125185529.GJ17873@fieldses.org>
 <20120125152356.10bdd772@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120125152356.10bdd772@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 03:23:56PM -0500, Jeff Layton wrote:
> I suggest that we only allow the reclaim of locks
> on the original address against which they were established.

I'm not sure what that means.

If a server stops responding, the v4.0 client has two choices: it can
either wait for the server to come back, and reclaim when it does.  Or
if it supports failover it can go find another server and perform
reclaims over there.

I'm a little unclear how it does that, but I suppose it first tests
somehow to see whether its existing state is supported, and if not, it
establishes a new clientid with SETCLIENTID/SETCILENTID_CONFIRM using
its old name, and then attempts to reclaim.

You're now requiring it *not* to do that if it happens that the servers
all rebooted in the meantime.  How does it know that that's what
happened?

Or maybe that's not what you want to require, I'm not sure.

--b.
