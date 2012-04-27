Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:44951 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756904Ab2D0QFy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Apr 2012 12:05:54 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFSv4 UCS client implementation experience
Date: Fri, 27 Apr 2012 12:05:44 -0400
Message-Id: <BF46E9F2-5675-4914-AD5F-9F43CDE9DBD4@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Noveck <david.noveck@emc.com>,
        Bill Baker <Bill.Baker@oracle.com>,
        piyush shivam <piyush.shivam@oracle.com>
To: nfsv4@ietf.org
Mime-Version: 1.0 (Apple Message framework v1257)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


During the working group meeting at IETF 83, the WG chair asked me about the implementation status of the Linux client migration implementation.  I never properly answered his question, so let me open this note with a brief update.  This update provides context for what follows.

Last summer I had support for NFS4ERR_MOVED, NFS4ERR_LEASE_MOVED, and transparent state migration working in the Linux NFS client.  At the time we used various protocol hacks to ensure that servers could recognize and manage migrated state.  After IETF 81 (Quebec City, August 2011), Dave Noveck conceived of using a Uniform Client String (UCS) model, where a client uses the same nfs_client_id4 string for all servers, to replace these hacks.  Since then I've been working on a UCS client prototype to test the idea.

This UCS client does not yet support migration.  Migration support can be forward ported from last summer's prototype after a UCS implementation is in place and robust.  My UCS client uses the same nfs_client_id4 for all servers.  It performs the SETCLIENTID operation as the first operation after it first contacts a server.  It then performs a degenerate form of server trunking discovery, since the Linux client does not currently support either client or server trunking.  Trunking discovery is performed at mount time only, not during lease reclaim.

Lastly, because not all server implementations are entirely compatible with UCS, the UCS client uses non-UCS by default.  UCS operation is enabled via a mount option when an administrator is certain the server can tolerate UCS clients.

My focus has recently shifted so that current work is now intended to be merged into the Linux mainline kernel.  That is, this is no longer protocol prototyping work: it is meant to be a real implementation.

However, we are still engaged in completing the NFSv4 migration draft which Dave started last fall.  As part of that engagement, I'd like to report further implementation experience since Connectathon 2012, when we last published the status of this work.


1. UCS clients must sustain empty leases to make trunking discovery work

The Linux client currently RENEWs its leases only when there is open or lock state.  It lets a lease expire if no state is held.  Thus a fresh SETCLIENTID / SETCLIENTID_CONFIRM sequence is needed before a subsequent OPEN can proceed.

A server can return a different clientid4 at this time.  However, our trunking discovery algorithm depends on the clientid4 not changing during the lifetime of mounts, even if no open or lock state is held.

For example, if I mount a server via address A, allow the lease to expire, then mount the same server via address B, the server may return a different clientid4 if it has no record of the expired lease.  The client then has no way to determine that address A and B represent the same server.

Therefore, a UCS client is obliged to continue RENEWing an empty lease so that it pins a clientid4 that can be used for server trunking discovery during future mount operations.


2.  The current Linux NFS server implementation does not tolerate UCS clients

I tried a simple test with the Linux UCS client and current stock NFS server implementations.  I mounted each server via NFSv4.0 by its IPv4 and its IPv6 address.  The UCS client's server trunking discovery algorithm should recognize that these addresses represent the same server instance.  For a Solaris 11 FCS server, this worked as expected.

For the Linux Fedora 16 server, this test failed.  The server returned a different clientid4 for the second mount, even though the client presented the same nfs_client_id4 and boot verifier, and the first mount's lease had not expired.  In addition, the server responded with NFS4ERR_CLID_INUSE when the client attempted a SETCLIENTID_CONFIRM.  The second mount was thus prevented.  The Linux NFS community agrees the Linux server's behavior is incorrect.

More important, this is another example of a widely deployed server implementation that does not tolerate UCS clients.  At least one of these misbehaviors appears as far back as we have kernel source repository history (roughly 2.6.12).  I have not yet tested the Linux server's NFSv4.1 implementation to see if it is also a victim of these bugs.


3.  NFSv4.0 UCS clients must merge callback IDs after trunking discovery

Server trunking discovery proceeds after a client performs a SETCLIENTID against an unrecognized server address.  If the server has already been contacted by this client via a different address, it should treat the current SETCLIENTID as a callback update.

However, if the client implementation uses a callback ID (or a uniquified callback RPC program number), it will likely have generated a fresh callback ID (or program number) for the current SETCLIENTID.  Thus this callback update will have replaced the existing callback information on the server that was established for previous mounts.

A client must ensure that callbacks for all existing mounts are still recognized.  Therefore, after server trunking discovery identifies a trunked server, a client must ensure its own data structures are updated to reflect the changed callback endpoint which is a byproduct of trunking discovery.

If callbacks using that ID will no longer be recognized by a client, it should consider terminating existing callback transport sessions for this clientid4 in order to signal that some callbacks could have been lost during the callback update.


4.  CLID_INUSE recovery for UCS clients may be difficult or impossible

RFC 3530bis suggests that a server returns CLID_INUSE only when an nfs_client_id4 string is presented with a different authentication flavor than a previous SETCLIENTID, and the lease for that string is still active.

Some servers can be more paranoid about nfs_client_id4 spoofing than others.  They sometimes return CLID_INUSE if the same nfs_client_id4 string is presented from different source IP addresses.  We believe this is incorrect behavior, yet it does exist in the diaspora, as we saw in 2. above.

For an NFSv4.0 UCS client, during server trunking discovery, a CLID_INUSE error is a sign that the server is trunked and does recognize the nfs_client_id4 string.  This is likely to occur, for example, if a client mounts a server via address A with authentication flavor X, then mounts address B with authentication flavor Y.

Possible recovery steps are to retry the SETCLIENTID with all supported authentication flavors so that a clientid4 can be obtained to perform server trunking discovery.  The outcome is that the client should continue to use the authentication flavor of the original SETCLIENTID (X, in our example above).

It may be difficult for either the client or server to distinguish trunking from nfs_client_id4 spoofing, however.

During lease reclaim, a CLID_INUSE error signifies that either another client is using the same nfs_client_id4 string with a different authentication flavor, or that lease reclaim has raced with another mount request on this client.  We can prevent the race in our client, but there does not seem to be a robust automatic recovery mechanism when client spoofing is encountered.  At this point, a client should probably cause all further application requests associated with the spoofed nfs_client_id4/clientid4 to fail.

Because nfs_client_id4 spoofing can be so destructive, my UCS client provides a mechanism for specifying a permanent client string uniquifier via a kernel boot option.  OS installation procedures can generate a UUID and then add it to the default kernel boot command line.  This provides a very strong (but still not perfect) guarantee of nfs_client_id4 uniqueness.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




