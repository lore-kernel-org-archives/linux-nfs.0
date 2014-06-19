Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f52.google.com ([209.85.192.52]:39773 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932775AbaFSOx1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:53:27 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so2239838qge.11
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:53:26 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 104/104] nfsd: add file documenting new state object model
Date: Thu, 19 Jun 2014 10:50:50 -0400
Message-Id: <1403189450-18729-105-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 .../filesystems/nfs/nfsd4-state-objects.txt        | 110 +++++++++++++++++++++
 1 file changed, 110 insertions(+)
 create mode 100644 Documentation/filesystems/nfs/nfsd4-state-objects.txt

diff --git a/Documentation/filesystems/nfs/nfsd4-state-objects.txt b/Documentation/filesystems/nfs/nfsd4-state-objects.txt
new file mode 100644
index 000000000000..fa3f70608422
--- /dev/null
+++ b/Documentation/filesystems/nfs/nfsd4-state-objects.txt
@@ -0,0 +1,110 @@
+KNFSD4 State Object Model:
+==========================
+Written 2014 by Jeff Layton <jlayton@primarydata.com>
+
+Introduction:
+-------------
+Until recently, knfsd relied heavily on a global mutex to ensure that objects
+didn't disappear while they were being operated on. That has proven to be a
+scalability bottleneck however, so the code has been overhauled to make heavy
+use of reference counting and spinlocks for tracking the different objects.
+
+The state model in NFSv4 is quite complex. Thus, the relationship between the
+objects to track this state in knfsd is also complex. This document attempts to
+lay out how all of the different objects relate to one another, and which ones
+hold references to others.
+
+In addition to the "persistent" references documented here, references to these
+objects can also be taken during the processing of compounds in order to ensure
+that the objects don't disappear suddenly.
+
+struct nfsd_net:
+----------------
+Represents a nfsd "container". With respect to nfsv4 state tracking, the fields
+of interest are the *_id_hashtbls and the *_name_tree. These track the
+nfs4_client objects by either short or long form clientid.
+
+Each nfsd_net runs a nfs4_laundromat workqueue job every lease period to clean
+up expired clients and delegations within the container.
+
+struct nfs4_file:
+-----------------
+These objects are global. nfsd only keeps one instance of a nfs4_file per inode
+(though it may keep multiple file descriptors open per inode). These are
+tracked in the file_hashtbl which is protected by the state_lock spinlock.
+
+struct nfs4_client:
+-------------------
+The initial object created by an NFS client using SETCLIENTID (for NFSv4.0) or
+EXCHANGE_ID (for NFSv4.1+). These objects are refcounted and timestamped. Each
+nfsd_net_ns object contains a set of these and they are tracked via short and
+long form clientid. They are hashed and searched for under the per-nfsd-net
+client_lock spinlock.
+
+The lifecycle of these is a little strange. References to it are only held
+during the processing of compounds, and in certain other operations. In their
+"resting state" they have a refcount of 0. If they are not renewed within a
+lease period, they become eligible for destruction by the laundromat.
+
+These objects can also be destroyed prematurely by the fault injection code,
+or if the client sends certain forms of SETCLIENTID or EXCHANGE_ID updates.
+Care is taken *not* to do this however when the objects have an elevated
+refcount.
+
+struct nfsd4_session:
+---------------------
+Represents a v4.1+ session. These are refcounted in a similar fashion to
+the nfs4_client. References are only taken when the server is actively working
+on the object (primarily during the processing of compounds).
+
+struct nfs4_stateowner:
+-----------------------
+A core object that represents either an open or lock owner. The object and lock
+owner objects have one of these embedded within them. Refcounts and other
+fields common to both owner types are contained within these structures.
+
+struct nfs4_openowner:
+----------------------
+When a file is opened, the client provides an open state owner opaque string
+that indicates the "owner" of that open. These objects are refcounted.
+References to it are held by each open state associated with it. This object is
+a superset of the nfs4_stateowner struct.
+
+struct nfs4_lockowner:
+----------------------
+Represents a generic "lockowner". Similar to an openowner. References to it are
+held by the lock stateids that are created on its behalf. This object is a
+superset of the nfs4_stateowner struct.
+
+strict nfs4_stid:
+-----------------
+A core object that represents a "generic" stateid. These are generally embedded
+within the different (more specific) stateid objects and contain fields that
+are of general use to any stateid.
+
+struct nfs4_ol_stateid:
+-----------------------
+A generic struct representing either a open or lock stateid. The nfs4_client
+holds a reference to each of these objects, and they in turn hold a reference
+to their respective stateowners. The client's reference is released in response
+to a close or unlock (depending on whether it's an open or lock stateid) or
+when the client is being destroyed.
+
+In the case of v4.0, these objects are preserved for a little while after close
+in order to handle CLOSE replays. They are eventually reclaimed via a LRU
+scheme by the laundromat.
+
+This object is a superset of the nfs4_stid.
+
+struct nfs4_delegation:
+-----------------------
+Represents a delegation stateid. The nfs4_client holds references to these and
+they are put when it is being destroyed or when the delegation is returned by
+the client.
+
+If the server attempts to recall a delegation and the client doesn't do so
+before a timeout, the server may also revoke the delegation. In that case, the
+object will either be destroyed (v4.0) or moved to a per-client list of revoked
+delegations (v4.1+).
+
+This object is a superset of the nfs4_stid.
-- 
1.9.3

