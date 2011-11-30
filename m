Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ogre.sisk.pl ([217.79.144.158]:36085 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780Ab1K3TkV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Nov 2011 14:40:21 -0500
From: "Rafael J. Wysocki" <rjw@sisk.pl>
To: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH v4 0/2] nfs/sunrpc: allow freezing of tasks with NFS calls in flight
Date: Wed, 30 Nov 2011 20:43:13 +0100
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-pm@vger.kernel.org, tj@kernel.org, john@calva.com,
        trond.myklebust@netapp.com, marek.belisko@gmail.com,
        awilliam@redhat.com
References: <1322570215-8570-1-git-send-email-jlayton@redhat.com>
In-Reply-To: <1322570215-8570-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Message-Id: <201111302043.13844.rjw@sisk.pl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday, November 29, 2011, Jeff Layton wrote:
> This patchset is the fourth attempt at fixing the issues with suspending
> a machine that has an active NFS mount.
> 
> The bug reported against Fedora is here:
> 
>     https://bugzilla.redhat.com/show_bug.cgi?id=717735
> 
> The main difference from v3 is that I've fixed a stupid set of errors in
> freezable_schedule_timeout_killable. The if condition was reversed from
> what it should have been, and the code did not call freezer_count()
> again when it was going to return early.
> 
> Tejun has mentioned that the extra try_to_freeze() calls are unnecessary
> on top of the pm-freezer changes, but this set should work on as
> expected on top of 3.2-ish kernels. In the meantime, I'll look over the
> pm-freezer changes and see whether I need to make changes in this set
> for 3.3.
> 
> Jeff Layton (2):
>   sunrpc: make rpc_wait_bit_killable handle freeze events
>   nfs: make TASK_KILLABLE sleeps attempt to freeze

Both patches applied to linux-pm/linux-next.  I'll move them to
linux-pm/pm-freezer in a couple of days if there are no problems with
them.

Thanks,
Rafael


>  fs/nfs/inode.c          |    3 ++-
>  fs/nfs/nfs3proc.c       |    3 ++-
>  fs/nfs/nfs4proc.c       |    5 +++--
>  fs/nfs/proc.c           |    3 ++-
>  include/linux/freezer.h |   42 ++++++++++++++++++++++++++++++++++++++++++
>  net/sunrpc/sched.c      |    3 ++-
>  6 files changed, 53 insertions(+), 6 deletions(-)
> 
> 

