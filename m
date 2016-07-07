Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33121 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbcGGQSM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Jul 2016 12:18:12 -0400
Received: by mail-it0-f67.google.com with SMTP id y93so3316306ita.0
        for <linux-nfs@vger.kernel.org>; Thu, 07 Jul 2016 09:18:11 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:ec4:7aff:fe6c:1dce])
        by smtp.gmail.com with ESMTPSA id q128sm1450282iod.30.2016.07.07.09.18.04
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 09:18:05 -0700 (PDT)
Subject: [PATCH] nfs(5): Add lease management security considerations
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 07 Jul 2016 12:18:03 -0400
Message-ID: <20160707161334.11055.52912.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Several years ago, the kernel Linux NFS client was changed to
attempt to use strong security for lease management operations that
are shared by all NFSv4 mounts of a server on that client.

This forces the client to use a consistent security flavor and
principal for lease management, even across reboots, to ensure that
state recovery works, independent of what mounts have been done,
what order they were done, and with what sec= option.

The use of krb5i for lease management does not affect the flavor
used for RPCs done on behalf of individual users, but sometimes it
means krb5i is used for certain operations even when "sec=sys" is
specified. This has occasionally been surprising.

Link: https://bugzilla.redhat.com/show_bug.cgi?id=1334510
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/mount/nfs.man |   59 ++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 56 insertions(+), 3 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index e541cdc..7cad556 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -1521,8 +1521,8 @@ but it does not protect their sideband protocols.
 .P
 The
 .B sec
-mount option specifies the security flavor
-that is in effect on a given NFS mount point.
+mount option specifies the security flavor used for operations
+on behalf of users on that NFS mount point.
 Specifying
 .B sec=krb5
 provides cryptographic proof of a user's identity in each RPC request.
@@ -1550,7 +1550,7 @@ expect some performance impact
 when using integrity checking or encryption.
 Similar support for other forms of cryptographic security
 is also available.
-.P
+.SS "NFS version 4 filesystem crossing"
 The NFS version 4 protocol allows
 a client to renegotiate the security flavor
 when the client crosses into a new filesystem on the server.
@@ -1560,6 +1560,59 @@ Such negotiation typically occurs when a client crosses
 from a server's pseudo-fs
 into one of the server's exported physical filesystems,
 which often have more restrictive security settings than the pseudo-fs.
+.SS "NFS version 4 Leases"
+In NFS version 4, a lease is a period of time during which a server
+irrevocably grants a file lock to a client.
+If the lease expires, the server is allowed to revoke that lock.
+Clients periodically renew their leases to prevent lock revocation.
+.P
+After an NFS version 4 server reboots, each client tells the
+server about all file open and lock state under its lease
+before operation can continue.
+If the client reboots, the server frees all open and lock state
+associated with that client's lease.
+.P
+As part of establishing a lease, therefore,
+a client must identify itself to a server.
+A fixed string is used to distinguish that client from
+others, and a changeable verifier is used to indicate
+when the client has rebooted.
+.P
+A client uses a particular security flavor and principal
+when performing the operations to establish a lease.
+If two clients happen to present the same identity string,
+a server can use their principals to detect that they are
+different clients, and prevent one client from interfering
+with the other's lease.
+.P
+The Linux NFS client establishes one lease for each server.
+Lease management operations, such as lease renewal, are not
+done on behalf of a particular file, lock, user, or mount
+point, but on behalf of the whole client that owns that lease.
+These operations must use the same security flavor and
+principal that was used when the lease was established,
+even across client reboots.
+.P
+When Kerberos is configured on a Linux NFS client
+(i.e., there is a
+.I /etc/krb5.keytab
+on that client), the client attempts to use a Kerberos
+security flavor for its lease management operations.
+This provides strong authentication of the client to
+each server it contacts.
+By default, the client uses the
+.I host/
+or
+.I nfs/
+service principal in its
+.I /etc/krb5.keytab
+for this purpose.
+.P
+If the client has Kerberos configured, but the server
+does not, or if the client does not have a keytab or
+the requisite service principals, the client uses
+.I AUTH_SYS
+and UID 0 for lease management.
 .SS "Using non-privileged source ports"
 NFS clients usually communicate with NFS servers via network sockets.
 Each end of a socket is assigned a port value, which is simply a number

