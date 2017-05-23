Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57358 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757989AbdEWQN0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 23 May 2017 12:13:26 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87lgpoww67.fsf@xmission.com>
References: <87lgpoww67.fsf@xmission.com> <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
To: ebiederm@xmission.com (Eric W. Biederman)
Cc: dhowells@redhat.com, trondmy@primarydata.com, mszeredi@redhat.com,
        linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org
Subject: Re: [RFC][PATCH 0/9] Make containers kernel objects
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 23 May 2017 17:13:18 +0100
Message-ID: <3612.1495555998@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric W. Biederman <ebiederm@xmission.com> wrote:

> Let me suggest a concrete alternative:
> 
> - At the time of mount observer the mounters user namespace.

Looking at sget(), I don't think a mounter can see a superblock outside of
their namespace.  There is something icky in there whereby all automounts are
currently transferred into the init_user_ns though (something to fix in my
mount-context series) :-/

> - Find the mounters pid namespace.
> - If the mounters pid namespace is owned by the mounters user namespace
>   walk up the pid namespace tree to the first pid namespace owned by
>   that user namespace.
> - If the mounters pid namespace is not owned by the mounters user
>   namespace fail the mount it is going to need to make upcalls as
>   will not be possible.

Take the following scenario:

 (1) Create a process with a new network namespace.  Set up the network to
     route out of ethernet port 1.

 (2) Create a child process with new network and user namespaces.  Set up the
     network to route out of ethernet port 2.

 (3) Mount an NFS volume in the process created in (2).

The mount in (3) will fail unconditionally.

> - Hold a reference to the pid namespace that was found.

Take the following scenario:

 (1) Create a process with new network and pid namespaces.  Set up the network
     to route out of ethernet port 1.

 (2) Create a child process with new network and pid namespaces.  Set up the
     network to route out of ethernet port 2.

 (3) Mount an NFS volume in the process created in (2).

 (4) Create another child process with new network and pid namespaces.  Set up
     the network to route out of ethernet port 3.

 (5) In the process created in (4), access the NFS volume created in (3).

The user namespace is the same all the way through.

Now you're holding a ref to the pid namespace created in (1) - but that is of
no use to you.  The upcall must take place in the network namespace that
routes out through port 2.

David
