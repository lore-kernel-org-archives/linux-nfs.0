From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/4] nfsd: add support for NFSv4 callbacks over IPv6
Date: Wed, 17 Jun 2009 15:01:47 -0400
Message-ID: <20090617150147.39303bec@tlielax.poochiereds.net>
References: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
	<20090617184701.GD24040@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51252 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758609AbZFQTBw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Jun 2009 15:01:52 -0400
In-Reply-To: <20090617184701.GD24040@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 17 Jun 2009 14:47:01 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Jun 17, 2009 at 02:15:37PM -0400, Jeff Layton wrote:
> > This patchset is a first pass at adding IPv6 callback channel support
> > for knfsd. The set is fairly straightforward, but it does require a
> > number of changes to server side NFSv4 related structs that store
> > addresses in places that are only suitable for IPv4 addresses.
> > 
> > I've tested this by having Linux and OpenSolaris clients mount the
> > server over an IPv6 socket, get a delegation and ensure that the server
> > can recall that delegation. It all seems to work as expected. IPv4
> > callbacks also seem to continue to work correctly.
> > 
> > This patchset does change the some of the new 4.1 functions
> > (nfsd4_exchange_id in particular). Those changes are untested as of yet
> > but I'll see if I can do so if the approach in this set seems
> > reasonable.
> 
> Thanks, just two quick comments:
> 
> 	1. I've been working on the callback code, so check that this
> 	applies against for-2.6.31 (at
> 	git://linux-nfs.org/~bfields/linux.git).

Sorry, I should have made it clear in the original email. This patchset
applies cleanly to your master branch. I just checked and it also
applies cleanly to your for-2.6.31 branch.

> 	2. Any IP address checks in setclientid or exchange_id are
> 	probably bogus; the former should be gone, the latter may still
> 	be there but there'll be a patch queued up for 2.6.31 to fix
> 	that.
> 

There are definitely still IP address comparisons in those functions,
though I confess I didn't look closely at the logic. My main concern
with this set was to move the IPv4 specific address containers to
sockaddr_storage, and to make the comparisons work for alternate
address families. I tried not to alter the logic however.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
