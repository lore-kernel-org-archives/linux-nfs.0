Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:41916 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755665AbeDTPfO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Apr 2018 11:35:14 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAHC9VhQhaBNBFwAXJ4TxKO56UTcwb_LcT2G8LwNxdxOD96tTvA@mail.gmail.com>
References: <CAHC9VhQhaBNBFwAXJ4TxKO56UTcwb_LcT2G8LwNxdxOD96tTvA@mail.gmail.com> <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk> <152414469006.23902.8132059438921850399.stgit@warthog.procyon.org.uk>
To: Paul Moore <paul@paul-moore.com>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org,
        selinux@tycho.nsa.gov
Subject: Re: [PATCH 04/24] VFS: Add LSM hooks for filesystem context [ver #7]
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Fri, 20 Apr 2018 16:35:11 +0100
Message-ID: <3232.1524238511@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul Moore <paul@paul-moore.com> wrote:

> Adding the SELinux mailing list to the CC line; in the future please
> include the SELinux mailing list on patches like this.  It would also
> be very helpful to include "selinux" somewhere in the subject line
> when the patch is predominately SELinux related (much like you did for
> the other LSMs in this patchset).

I should probably evict the SELinux bits into their own patch since the point
of this patch is the LSM hooks, not specifically SELinux's implementation
thereof.

> I can't say I've digested all of this yet, but what SELinux testing
> have you done with this patchset?

Using the fsopen()/fsmount() syscalls, these hooks will be made use of, say
for NFS (which I haven't included in this list).  Even sys_mount() will make
use of them a bit, so just booting the system does that.

Note that for SELinux these hooks don't change very much except how the
parameters are handled.  It doesn't actually change the checks that are made -
at least, not yet.  There are some additional syscalls under consideration
(such as the ability to pick a live mounted filesystem into a context) that
might require additional permits.

David
