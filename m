Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59636 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756025Ab0CIBpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 20:45:05 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1NooWf-000258-UH
	for linux-nfs@vger.kernel.org; Mon, 08 Mar 2010 20:46:26 -0500
Date: Mon, 8 Mar 2010 20:46:25 -0500
To: linux-nfs@vger.kernel.org
Subject: reboot recovery
Message-ID: <20100309014624.GF2999@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The Linux server's reboot recovery code has long-standing architectural
problems, fails to adhere to the specifications in some cases, and does
not yet handle NFSv4.1 reboot recovery.  An overhaul has been a
long-standing todo.

This is my attempt to state the problem and a rough solution.

Requirements
^^^^^^^^^^^^

Requirements, as compared to current code:

	- Correctly implements the algorithm described in section 8.6.3
	  of rfc 3530, and eliminates known race conditions on recovery.
	- Does not attempt to manage files and directories directly from
	  inside the kernel.
	- Supports RECLAIM_COMPLETE.

Requirements, in more detail:

A "server instance" is the lifetime from start to shutdown of a server;
a reboot ends one server instance and starts another.  Normally a server
instance consists of a grace period followed by a period of normal
operation.  However, a server could go down before the grace period
completes.  Call a server instance that completes the grace period
"full", and one that does not "partial".

Call a client "active" if it holds unexpired state on the server.  Then:

	- An NFSv4.0 client becomes active as soon as it succesfully
	  performs its first OPEN_CONFIRM, or its first reclaim OPEN.
	- An NFSv4.1 client becomes active when it succesfully performs
	  its first OPEN, or a RECLAIM_COMPLETE.
	- Active clients become inactive when they expire.  (Or when
	  they are revoked--but the Linux server does not currently
	  support revocation.)
	- On startup all clients are initially inactive.

On startup the server needs access to the list of clients which are
permitted to reclaim state.  That list is exactly the list of clients
that were active at the end of the most recent full server instance.

To maintain such a list, we need records to be stored in stable storage.
Whenever a client changes from inactive to active, or active to
inactive, stable storage must be updated, and until the update has
completed the server must do nothing that acknowledges the new state.
So:

	- When a new client becomes active, a record for that client
	  must be created in stable storage before responding to the rpc
	  in question (OPEN, OPEN_CONFIRM, or RECLAIM_COMPLETE).
	- When a client expires, the record must be removed (or
	  otherwise marked expired) before responding to any requests
	  for locks or other state which would conflict with state held
	  by the expiring client.

Updates must be made by upcalls to userspace; the kernel will not be
directly involved in managing stable storage.  The upcall interface
should be extensible.

The records must include the client owner name, to allow identifying
clients on restart.  The protocol allows client owner names to consist
of up to 1024 bytes of binary data.  (This is the client-supplied
long form, not the server-generated shorthand clientid; co_ownerid for
4.1).

Also desireable, but not absolutely required in the first
implementation:

	- We should not take the state lock while waiting for records to
	  be stored.  (Doing so blocks all other stateful operations
	  while we wait for disk.)
	- The server should be able to end the grace period early when
	  the list of clients allowed to reclaim is empty, or when they
	  are all 4.1 clients, after all have sent RECLAIM_COMPLETE.
	- Will allow pluggable methods for storage of reboot recovery
	  records, as the NFSv2 and NFSv3 code currently does (in order
	  to support high-availability).

Possibly also desireable:

	- Record the principal that originally created the client, and
	  whether it had EXCHGID4_FLAG_BIND_PRINC_STATEID (see rfc 5661
	  section 8.4.2.1).

Draft design
^^^^^^^^^^^^

We will modify rpc.statd to handle to manage state in userspace.

Previous prototype code from CITI will be considered as a starting
point.

Kernel<->user communication will use four files in the "nfsd"
filesystem.  All of them will use the encoding used for rpc cache
upcalls and downcalls, which consist of whitespace-separated fields
escaped as necessary to allow binary data.

Three of them will be used for upcalls; statd reads request from them,
and writes responses back:

create_client:
	- given a client owner, returns an error.  Does not return until
	  a new record has safely been recorded on disk.

grace_done:
	- request and reply are both empty; rpc.statd returns only after
	  it has recorded to disk the fact that the grace period
	  completed.

expire_client:
	- given a client owner, replies with an empty reply.  Replies
	  only after it has recorded to disk the fact that the client
	  has expired.

One additional file will be used for a downcall:

allow_client:
	- before starting the server, statd will open this file, write a
	  newline-separated list of client owners permitted to recover,
	  then close the file.  If no clients are allowed to recover, it
	  will still open and close the file.

Statd will use the presence of these upcalls to determine whether the
server supports the new recovery mechanism.  nfsd may use rpc.statd's
open of allow_client to decide whether userspace supports the new
mechanism.  Thus allows a mismatched kernel and userspace to still
maintain reboot recovery records.

In addition, we could support seamless reboot recovery across the
transition to the new system by making statd convert between on-disk
formats.  However, for simplicity's sake we plan for the server to be
refuse all reclaims on the first boot after the transition.

By default, statd will store records as files in the directory
/var/lib/nfs/v4clients.  The file name will be a hash of the
client_owner, and the contents will consist of two newline-separated
fields:
	- The client owner, encoded as in the upcall.
	- A timestamp.

More fields may be added in the future.

Before starting the server, and writing to allow_client, statd will
manage boot times and old clients using files in /var/lib/nfs:

	If boot_time exists:
		- It will be read, and the contents interpreted as an
		  ascii-encoded unix time in seconds.
		- All client records older than that time will be removed.
		- The current boot_time will be recorded to
		  new_boot_time (replacing any existing such file).
		- All remaining clients will be written to allow_client.
	If boot_time does not exist, an empty /var/lib/nfs/v4clients/ is
		created if necessary, but nothing else is done.

Statd will then wait for create_client, expire_client, and grace_done
calls.  On grace_done, it will rename boot_time to old_boot_time, and
new_boot_time to boot_time.

--b.
