Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:43367 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755928Ab1HSTqI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Aug 2011 15:46:08 -0400
Date: Fri, 19 Aug 2011 20:08:29 +0100
From: Jamie Lokier <jamie@shareable.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Volker Lendecke <Volker.Lendecke@SerNet.DE>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, samba-technical@lists.samba.org,
        Casey Bodley <cbodley@citi.umich.edu>
Subject: Re: [PATCH] locks: breaking read lease should not block read open
Message-ID: <20110819190829.GD11512@jl-vm1.vm.bytemark.co.uk>
References: <20110609231606.GB22215@fieldses.org>
 <E1QUwaT-00HRZw-74@intern.SerNet.DE>
 <20110610134859.GA27837@fieldses.org>
 <20110721000758.GD27871@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110721000758.GD27871@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> I'm not sure how to approach the lease code.
> 
> On the one hand, I've never seen any evidence that anyone outside Samba
> and NFSv4 has ever used it, and both currently make extremely limited
> use of it.  So we could probably get away with "fixing" the lease code
> to do whatever both of us need.

I've never used it, but I've _nearly_ used it (project took a
different direction), in a web application framework.

Pretty much the way CIFS/NFS use it, to keep other things (remote
state, database state, derived files) transactionally coherent with
changes to file contents by programs that only know about the files
they access.

The SIGIO stuff is a horrible interface.
I could still see me trying to use it sometime in the future.
In which case I really don't mind if you make the semantics saner :-)

Now we have fanotify which does something very similar and could have
generalised leases, but unfortunately fanotify came from such a
different motivation that it's not well suited for ordinary user
applications.

-- Jamie
