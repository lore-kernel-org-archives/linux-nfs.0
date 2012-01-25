Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:31545 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602Ab2AYV3M convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jan 2012 16:29:12 -0500
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120125212553.GA22216@fieldses.org>
Date: Wed, 25 Jan 2012 16:29:02 -0500
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <A8128BCD-0914-4D2B-81BF-A4A4EF0F2561@oracle.com>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com> <20120124230855.GE12426@fieldses.org> <20120125064158.4551a012@tlielax.poochiereds.net> <20120125131116.GA17873@fieldses.org> <20120125083820.637c8362@tlielax.poochiereds.net> <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com> <20120125171401.GI17873@fieldses.org> <D13C2C6D-7731-4EE6-BC3D-2A9D1D1F0581@oracle.com> <20120125185529.GJ17873@fieldses.org> <20120125152356.10bdd772@tlielax.poochiereds.net> <20120125212553.GA22216@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 25, 2012, at 4:25 PM, J. Bruce Fields wrote:

> On Wed, Jan 25, 2012 at 03:23:56PM -0500, Jeff Layton wrote:
>> I suggest that we only allow the reclaim of locks
>> on the original address against which they were established.
> 
> I'm not sure what that means.
> 
> If a server stops responding, the v4.0 client has two choices: it can
> either wait for the server to come back, and reclaim when it does.  Or
> if it supports failover it can go find another server and perform
> reclaims over there.

Honestly, I don't think that's possible in NFSv4.0.

The richer information provided by fs_locations_info can allow the client to determine whether two servers share more than simply data.  That information does not exist in NFSv4.0, so there's no way a client can expect that two servers lists in fs_locations results will always have the same NFSv4 state.

Thus I believe that NFSv4.0 replication is limited to read-only data.  But I have to go back and read that chapter of 3530 again.

> I'm a little unclear how it does that, but I suppose it first tests
> somehow to see whether its existing state is supported, and if not, it
> establishes a new clientid with SETCLIENTID/SETCILENTID_CONFIRM using
> its old name, and then attempts to reclaim.
> 
> You're now requiring it *not* to do that if it happens that the servers
> all rebooted in the meantime.  How does it know that that's what
> happened?
> 
> Or maybe that's not what you want to require, I'm not sure.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




