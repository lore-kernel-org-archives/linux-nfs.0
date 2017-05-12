Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755231AbdELOeU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 May 2017 10:34:20 -0400
Date: Fri, 12 May 2017 10:34:11 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Stefan Hajnoczi <stefanha@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170512143410.GC17983@parsley.fieldses.org>
References: <20170512132721.GA654@stefanha-x1.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170512132721.GA654@stefanha-x1.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 12, 2017 at 09:27:21AM -0400, Stefan Hajnoczi wrote:
> Hi,
> I've been working on NFS over the AF_VSOCK transport
> (https://www.spinics.net/lists/linux-nfs/msg60292.html).  AF_VSOCK
> resets established network connections when the virtual machine is
> migrated to a new host.
> 
> The NFS client expects file handles and other state to remain valid upon
> reconnecting.  This is not the case after VM live migration since the
> new host does not have the NFS server state from the old host.
> 
> Volatile file handles have been suggested as a way to reflect that state
> does not persist across reconnect, but the Linux NFS client does not
> support volatile file handles.

That's unlikely to change; the protocol allows the server to advertise
volatile filehandles, but doesn't really give any tools to implement
them reliably.

> I saw NFS 4.1 has a way for a new server running with the same network
> address of an old server to communicate that it is indeed a new server
> instance.  If the server owner/scope in the EXCHANGE_ID response does
> not match the previous server's values then the server is a new
> instance.
> 
> The implications of encountering a new server owner/scope upon reconnect
> aren't clear to me and I'm not sure to what extent the Linux
> implementation handles this case.  Can anyone explain what happens if
> the NFS client finds a new server owner/scope after reconnecting?

I haven't tested it, but if it reconnects to the same IP address and
finds out it's no longer talking to the same server, I think the only
correct thing it could do would be to just fail all further access.

There's no easy solution.

To migrate between NFS servers you need some sort of clustered NFS
service with shared storage.  We can't currently support concurrent
access to shared storage from multiple NFS servers, so all that's
possible active/passive failover.  Also, people that set that up
normally depend on a floating IP address--I'm not sure if there's an
equivalent for VSOCK.

--b.
