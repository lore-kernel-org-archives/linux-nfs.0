Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ogre.sisk.pl ([217.79.144.158]:60772 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753687Ab1K1VEP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Nov 2011 16:04:15 -0500
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 0/2] nfs/sunrpc: allow freezing of tasks with NFS calls in flight
Date: Mon, 28 Nov 2011 22:07:06 +0100
Cc: Jeff Layton <jlayton@redhat.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-pm@vger.kernel.org, john@calva.com,
        trond.myklebust@netapp.com, marek.belisko@gmail.com,
        awilliam@redhat.com
References: <1322510488-21189-1-git-send-email-jlayton@redhat.com> <201111282122.53635.rjw@sisk.pl> <20111128204024.GH18864@google.com>
In-Reply-To: <20111128204024.GH18864@google.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201111282207.07098.rjw@sisk.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday, November 28, 2011, Tejun Heo wrote:
> On Mon, Nov 28, 2011 at 09:22:53PM +0100, Rafael J. Wysocki wrote:
> > If no one objects, I'll take these patches to linux-pm/linux-next in the
> > next couple of days (and then to the pm-freezer branch, if there are no
> > visible problems with them).
> 
> Rafael, I think these need to be routed through pm-freezer branch.
> Freezer went through a lot of changes and I don't think this will work
> reliably without the freezer changes.

The linux-next branch contains pm-freezer (or at least it's supposed to).

The point is to let the patches stay in linux-next for a couple of days
before moving them to the pm-freezer branch to see if there's any fallout (I'm
not going to rebase pm-freezer, so fixing it will require addtional commits).

Thanks,
Rafael
