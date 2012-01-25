Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50825 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756398Ab2AYROE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jan 2012 12:14:04 -0500
Date: Wed, 25 Jan 2012 12:14:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 0/6] nfsd: overhaul the client name tracking code
Message-ID: <20120125171401.GI17873@fieldses.org>
References: <1327348867-699-1-git-send-email-jlayton@redhat.com>
 <20120124230855.GE12426@fieldses.org>
 <20120125064158.4551a012@tlielax.poochiereds.net>
 <20120125131116.GA17873@fieldses.org>
 <20120125083820.637c8362@tlielax.poochiereds.net>
 <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F6C58345-828B-493E-9D0E-8BBC60E348CF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 11:47:41AM -0500, Chuck Lever wrote:
> I'm having a hard time following the discussion, I must be lacking some context.  But the problem is how NFSv4.0 clients detect server identity.  The only way they can do it is by performing a SETCLIENTID_CONFIRM with a particular clientid4 against every server a client knows about.  If the clientid4 is recognized by multiple server IPs, the client knows these IPs are the same server.
> 
> Thus if you are preserving clientid4's on stable storage, it seems to me that you need to preserve the relationship between a clientid4 and which servers recognize it.

The part I'm having trouble thinking about:

Suppose your cluster nodes all advertise each other as replicas using
v4 (fs_locations or fs_locations_info).

Suppose your clients support (v4-based) failover, either transparent or
not.

Now suppose your cluster reboots.

Must the client necessarily reclaim its locks against the same server
that it last acquired them from?  And if not, how do we decide whether a
given reclaim is allowed or not?

I think there may be scenarios involving server reboots and the client
losing contact with some but not all servers, where we could get
confused about which (if any) state the client is allowed to reclaim.

--b.
