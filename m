Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46917 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933319AbcJUOWX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2016 10:22:23 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v2 01/10] SUNRPC: add AF_VSOCK support to addr.[ch]
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20161021130408.GG4648@stefanha-x1.localdomain>
Date: Fri, 21 Oct 2016 10:22:14 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Message-Id: <141D226A-071C-4486-AC0B-06862F206600@oracle.com>
References: <1475834514-4058-1-git-send-email-stefanha@redhat.com> <1475834514-4058-2-git-send-email-stefanha@redhat.com> <E1AFFD7C-D0D3-495E-BB11-94358FF31DBA@oracle.com> <20161021130408.GG4648@stefanha-x1.localdomain>
To: Stefan Hajnoczi <stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 21, 2016, at 9:04 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
> 
> On Fri, Oct 07, 2016 at 11:15:20AM -0400, Chuck Lever wrote:
>>> On Oct 7, 2016, at 6:01 AM, Stefan Hajnoczi <stefanha@redhat.com> wrote:
>>> 
>>> AF_VSOCK addresses are a Context ID (CID) and port number tuple.  The
>>> CID is a unique address, similar to a IP address on a local subnet.
>>> 
>>> Extend the addr.h functions to handle AF_VSOCK addresses.
> 
> Thanks for your reply.  A lot of these areas are covered in the
> presentation I gave at Connectathon 2016.  Here is the link in case
> you're interested:
> http://vmsplice.net/~stefan/stefanha-connectathon-2016.pdf
> 
> Replies to your questions below:
> 
>> I'm wondering if there's a specification for how to construct
>> the universal address form of an AF_VSOCK address. This would
>> be needed for populating an fs_locations response, or for
>> updating the NFS server's local rpcbind service.
> 
> The uaddr format I'm proposing is "vsock:cid.port".  Both cid and port
> are unsigned 32-bit integers.  The netid I'm proposing is "vsock".
> 
>> A traditional NFS server employs IP-address based access
>> control. How does that work with the new address family? Do
>> you expect changes to mountd or exportfs?
> 
> Yes, the /etc/exports syntax I'm proposing is:
> 
>  /srv/vm001 vsock:5(rw)
> 
> This allows CID 5 to access /srv/vm001.  The CID is equivalent to an IP
> address.
> 
> This patch series only addresses the NFS client side but I will be
> sending nfsd and nfs-utils rpc.mountd patches once I've completed the
> work.
> 
> The way it works so far is that /proc/net/rpc/auth.unix.ip is extended
> to support not just IP but also vsock addresses.  So the cache is
> separated by network address family (IP or vsock).
> 
>> Is there a standard that defines the "vsock" netid? A new
>> netid requires at least an IANA action. Is there a document
>> that describes how RPC works with a VSOCK transport?
> 
> I haven't submitted a request to IANA yet.  The RPC is the same as TCP
> (it uses the same Recording Marking to delimit boundaries in the
> stream).

>> This work appears to define two separate things: a new address
>> family, and a new transport type. Wouldn't it be cleaner to
>> dispense with the "proto=vsock" piece, and just support TCP
>> over AF_VSOCK (just as it works for AF_INET and AF_INET6) ?
> 
> Can you explain how this would simplify things?  I don't think much of
> the code is transport-specific (the stream parsing is already shared
> with TCP).  Most of the code is to add the new address family.  AF_VSOCK
> already offers TCP-like semantics natively so no extra protocol is used
> on top.

If this really is just TCP on a new address family, then "tcpv"
is more in line with previous work, and you can get away with
just an IANA action for a new netid, since RPC-over-TCP is
already specified.


>> At Connectathon, we discussed what happens when a guest is
>> live-migrated to another host with a vsock-enabled NFSD.
>> Essentially, the server at the known-local address would
>> change identities and its content could be completely
>> different. For instance, the file handles would all change,
>> including the file handle of the export's root directory.
>> Clients don't tolerate that especially well.
> 
> This issue remains.  I looked into checkpoint-resume style TCP_REPAIR to
> allow existing connections to persist across migration but I hope a
> simpler approach can be taken.
> 
> Let's forget about AF_VSOCK, the problem is that an NFS client loses
> connectivity to the old server and must connect to the new server.  We
> want to keep all state (open files, etc).  Are configurations like that
> possible with Linux nfsd?

You have two problems:

 - OPEN and LOCK state would appear to vanish on the server. To recover
this state you would need an NFS server restart and grace period on the
destination host to allow the client to use reclaiming OPENs.

 - The FSID and filehandles would be different.

You could mandate fixed well-known filehandles and FSIDs, just as you
are doing with the vsock addresses.

Or, implement NFSv4 migration in the Linux NFS server. Migrate the data
and the VM at the same time, then the filehandles and state can come
along for the ride, and no grace period is needed.


--
Chuck Lever



