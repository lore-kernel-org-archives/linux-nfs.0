Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:42563 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751407AbdELRBE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 13:01:04 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: EXCHANGE_ID with same network address but different server owner
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1494601295.10434.1.camel@primarydata.com>
Date: Fri, 12 May 2017 13:00:47 -0400
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
References: <20170512132721.GA654@stefanha-x1.localdomain> <20170512143410.GC17983@parsley.fieldses.org> <1494601295.10434.1.camel@primarydata.com>
To: "stefanha@redhat.com" <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 12, 2017, at 11:01 AM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Fri, 2017-05-12 at 10:34 -0400, J. Bruce Fields wrote:
>> On Fri, May 12, 2017 at 09:27:21AM -0400, Stefan Hajnoczi wrote:
>>> Hi,
>>> I've been working on NFS over the AF_VSOCK transport
>>> (https://www.spinics.net/lists/linux-nfs/msg60292.html).  AF_VSOCK
>>> resets established network connections when the virtual machine is
>>> migrated to a new host.
>>> 
>>> The NFS client expects file handles and other state to remain valid
>>> upon
>>> reconnecting.  This is not the case after VM live migration since
>>> the
>>> new host does not have the NFS server state from the old host.
>>> 
>>> Volatile file handles have been suggested as a way to reflect that
>>> state
>>> does not persist across reconnect, but the Linux NFS client does
>>> not
>>> support volatile file handles.
>> 
>> That's unlikely to change; the protocol allows the server to
>> advertise
>> volatile filehandles, but doesn't really give any tools to implement
>> them reliably.
>> 
>>> I saw NFS 4.1 has a way for a new server running with the same
>>> network
>>> address of an old server to communicate that it is indeed a new
>>> server
>>> instance.  If the server owner/scope in the EXCHANGE_ID response
>>> does
>>> not match the previous server's values then the server is a new
>>> instance.
>>> 
>>> The implications of encountering a new server owner/scope upon
>>> reconnect
>>> aren't clear to me and I'm not sure to what extent the Linux
>>> implementation handles this case.  Can anyone explain what happens
>>> if
>>> the NFS client finds a new server owner/scope after reconnecting?
>> 
>> I haven't tested it, but if it reconnects to the same IP address and
>> finds out it's no longer talking to the same server, I think the only
>> correct thing it could do would be to just fail all further access.
>> 
>> There's no easy solution.
>> 
>> To migrate between NFS servers you need some sort of clustered NFS
>> service with shared storage.  We can't currently support concurrent
>> access to shared storage from multiple NFS servers, so all that's
>> possible active/passive failover.  Also, people that set that up
>> normally depend on a floating IP address--I'm not sure if there's an
>> equivalent for VSOCK.
>> 
> 
> Actually, this might be a use case for re-exporting NFS. If the host
> could re-export a NFS mount to the guests, then you don't necessarily
> need a clustered filesystem.
> 
> OTOH, this would not solve the problem of migrating locks, which is not
> really easy to support in the current state model for NFSv4.x.

Some alternatives:

- Make the local NFS server's exports read-only, NFSv3
  only, and do not support locking. Ensure that the
  filehandles and namespace are the same on every NFS
  server.

- As Trond suggested, all the local NFS servers accessed
  via AF_SOCK should re-export NFS filesystems that
  are located elsewhere and are visible everywhere.

- Ensure there is an accompanying NFSv4 FS migration event
  that moves the client's files (and possibly its open and
  lock state) from the local NFS server to the destination
  NFS server concurrent with the live migration.

  If the client is aware of the FS migration, it will expect
  the filehandles to be the same, but it can reconstruct
  the open and lock state on the destination server (if that
  server allows GRACEful recovery for that client).

  This is possible in the protocol and implemented in the
  Linux NFS client, but none of it is implemented in the
  Linux NFS server.

--
Chuck Lever



