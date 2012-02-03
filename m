Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52532 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757764Ab2BCU6T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 3 Feb 2012 15:58:19 -0500
Date: Fri, 3 Feb 2012 15:58:18 -0500
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH 0/6] Fix NFSv4 delegations
Message-ID: <20120203205818.GE2999@fieldses.org>
References: <1326816029-13913-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1326816029-13913-1-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 17, 2012 at 11:00:23AM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> NFSv4 delegations are currently implemented as leases.  However, leases
> don't have quite the same semantics, which means that delegations are
> currently enforced correctly only for conflicts between NFSv4 clients.
> 
> I previously attempted to address this by "fixing" the existing lease
> behavior, assuming it was a bug--but from further investigation it looks
> like that would be the wrong thing to do for Samba.
> 
> So instead I'm defining a new FL_DELEG flag to mark NFSv4 delegations,
> and varying behavior based on that.  Delegations aren't meant to be
> available to userspace for now--nfsd is the only user.
> 
> In theory this code allows both read and write delegations, but I'm only
> using read delegations for now--write delegations are a project for
> another day.  (At which point write leases will probably need some
> fixing while we're at it.)
> 
> Still to do: if OPEN(dirfd, name) returns a delegation to the client,
> then the client should be guaranteed that the opened file is still
> linked as (dirfd, name).  But the current nfsd code allows a rename or
> unlink to intervene between the lookup and the request for a delegation.

OK, I decided I could fix that in the nfsd4 open code by retrying the
lookup after obtaining the delegation, and just dropping the delegation
(they're always optional) if it turned out there'd been a race.

I'll post revised vfs patches (without that extra nfsd stuff).

--b.
