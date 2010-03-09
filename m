Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:18376 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829Ab0CIRkt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 12:40:49 -0500
Message-ID: <4B9687D7.7010902@oracle.com>
Date: Tue, 09 Mar 2010 12:39:35 -0500
From: Chuck Lever <chuck.lever@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: reboot recovery
References: <20100309014624.GF2999@fieldses.org>
In-Reply-To: <20100309014624.GF2999@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks, this is very clear.

On 03/08/2010 08:46 PM, J. Bruce Fields wrote:
> The Linux server's reboot recovery code has long-standing architectural
> problems, fails to adhere to the specifications in some cases, and does
> not yet handle NFSv4.1 reboot recovery.  An overhaul has been a
> long-standing todo.
>
> This is my attempt to state the problem and a rough solution.
>
> Requirements
> ^^^^^^^^^^^^
>
> Requirements, as compared to current code:
>
> 	- Correctly implements the algorithm described in section 8.6.3
> 	  of rfc 3530, and eliminates known race conditions on recovery.
> 	- Does not attempt to manage files and directories directly from
> 	  inside the kernel.
> 	- Supports RECLAIM_COMPLETE.
>
> Requirements, in more detail:
>
> A "server instance" is the lifetime from start to shutdown of a server;
> a reboot ends one server instance and starts another.

It would be better if you architected this not in terms of a server 
reboot, but in terms of "service nfs stop" and "service nfs start".

> Normally a server
> instance consists of a grace period followed by a period of normal
> operation.  However, a server could go down before the grace period
> completes.  Call a server instance that completes the grace period
> "full", and one that does not "partial".
>
> Call a client "active" if it holds unexpired state on the server.  Then:
>
> 	- An NFSv4.0 client becomes active as soon as it succesfully
> 	  performs its first OPEN_CONFIRM, or its first reclaim OPEN.
> 	- An NFSv4.1 client becomes active when it succesfully performs
> 	  its first OPEN, or a RECLAIM_COMPLETE.
> 	- Active clients become inactive when they expire.  (Or when
> 	  they are revoked--but the Linux server does not currently
> 	  support revocation.)
> 	- On startup all clients are initially inactive.
>
> On startup the server needs access to the list of clients which are
> permitted to reclaim state.  That list is exactly the list of clients
> that were active at the end of the most recent full server instance.
>
> To maintain such a list, we need records to be stored in stable storage.
> Whenever a client changes from inactive to active, or active to
> inactive, stable storage must be updated, and until the update has
> completed the server must do nothing that acknowledges the new state.
> So:
>
> 	- When a new client becomes active, a record for that client
> 	  must be created in stable storage before responding to the rpc
> 	  in question (OPEN, OPEN_CONFIRM, or RECLAIM_COMPLETE).
> 	- When a client expires, the record must be removed (or
> 	  otherwise marked expired) before responding to any requests
> 	  for locks or other state which would conflict with state held
> 	  by the expiring client.
>
> Updates must be made by upcalls to userspace; the kernel will not be
> directly involved in managing stable storage.  The upcall interface
> should be extensible.
>
> The records must include the client owner name, to allow identifying
> clients on restart.  The protocol allows client owner names to consist
> of up to 1024 bytes of binary data.  (This is the client-supplied
> long form, not the server-generated shorthand clientid; co_ownerid for
> 4.1).
>
> Also desireable, but not absolutely required in the first
> implementation:
>
> 	- We should not take the state lock while waiting for records to
> 	  be stored.  (Doing so blocks all other stateful operations
> 	  while we wait for disk.)
> 	- The server should be able to end the grace period early when
> 	  the list of clients allowed to reclaim is empty, or when they
> 	  are all 4.1 clients, after all have sent RECLAIM_COMPLETE.
> 	- Will allow pluggable methods for storage of reboot recovery
> 	  records, as the NFSv2 and NFSv3 code currently does (in order
> 	  to support high-availability).
>
> Possibly also desireable:
>
> 	- Record the principal that originally created the client, and
> 	  whether it had EXCHGID4_FLAG_BIND_PRINC_STATEID (see rfc 5661
> 	  section 8.4.2.1).
>
> Draft design
> ^^^^^^^^^^^^
>
> We will modify rpc.statd to handle to manage state in userspace.

Please don't.  statd is ancient krufty code that is already barely able 
to do what it needs to do.

statd is single-threaded.  It makes dozens of blocking DNS calls to 
handle NSM protocol requests.  It makes NLM downcalls on the same thread 
that handles everything else.  Unless an effort was undertaken to make 
statd multithreaded, this extra work could cause signficant latency for 
handling upcalls.

> Previous prototype code from CITI will be considered as a starting
> point.
>
> Kernel<->user communication will use four files in the "nfsd"
> filesystem.  All of them will use the encoding used for rpc cache
> upcalls and downcalls, which consist of whitespace-separated fields
> escaped as necessary to allow binary data.

In general, we don't want to mix RPC listeners and upcall file 
descriptors.  mountd has to access the cache file descriptors to satisfy 
MNT requests, so there is a reason to do it in that case.  Here there is 
no purpose to mix these two.  It only adds needless implementation 
complexity and unnecessary security exposures.

Yesterday, it was suggested that we split mountd into a piece that 
handled upcalls and a piece that handled remote MNT requests via RPC. 
Weren't you the one who argued in favor of getting rid of daemons called 
"rpc.foo" for NFSv4-only operation? :-)

> Three of them will be used for upcalls; statd reads request from them,
> and writes responses back:
>
> create_client:
> 	- given a client owner, returns an error.  Does not return until
> 	  a new record has safely been recorded on disk.
>
> grace_done:
> 	- request and reply are both empty; rpc.statd returns only after
> 	  it has recorded to disk the fact that the grace period
> 	  completed.
>
> expire_client:
> 	- given a client owner, replies with an empty reply.  Replies
> 	  only after it has recorded to disk the fact that the client
> 	  has expired.
>
> One additional file will be used for a downcall:
>
> allow_client:
> 	- before starting the server, statd will open this file, write a
> 	  newline-separated list of client owners permitted to recover,
> 	  then close the file.  If no clients are allowed to recover, it
> 	  will still open and close the file.
>
> Statd will use the presence of these upcalls to determine whether the
> server supports the new recovery mechanism.  nfsd may use rpc.statd's
> open of allow_client to decide whether userspace supports the new
> mechanism.  Thus allows a mismatched kernel and userspace to still
> maintain reboot recovery records.

If you have a separate daemon: don't run the daemon on kernels that 
don't support NFSv4.1 reboot recovery upcalls.

> In addition, we could support seamless reboot recovery across the
> transition to the new system by making statd convert between on-disk
> formats.  However, for simplicity's sake we plan for the server to be
> refuse all reclaims on the first boot after the transition.
>
> By default, statd will store records as files in the directory
> /var/lib/nfs/v4clients.  The file name will be a hash of the
> client_owner, and the contents will consist of two newline-separated
> fields:
> 	- The client owner, encoded as in the upcall.
> 	- A timestamp.
>
> More fields may be added in the future.

> Before starting the server, and writing to allow_client, statd will
> manage boot times and old clients using files in /var/lib/nfs:
>
> 	If boot_time exists:
> 		- It will be read, and the contents interpreted as an
> 		  ascii-encoded unix time in seconds.
> 		- All client records older than that time will be removed.
> 		- The current boot_time will be recorded to
> 		  new_boot_time (replacing any existing such file).
> 		- All remaining clients will be written to allow_client.
> 	If boot_time does not exist, an empty /var/lib/nfs/v4clients/ is
> 		created if necessary, but nothing else is done.

Since I've split out the pieces of statd that manage its on-disk file 
format (see support/nsm/file.c) it shouldn't be difficult to 
copy-n-paste the pieces needed to construct /var/lib/nfs/v4clients.

I have some additional patches for statd that can detect system reboots, 
but again, it would be better perhaps to design for "server nfs restart" 
rather than a full system reboot.

> Statd will then wait for create_client, expire_client, and grace_done
> calls.  On grace_done, it will rename boot_time to old_boot_time, and
> new_boot_time to boot_time.

Although it's noble to attempt to reuse old code in this way, I think 
you will be far better off constructing and using a proper scaffold for 
dealing generically with cache upcalls.  By doing this we avoid the 
complexity of updating working legacy code, and have a better chance for 
building something that scales well right off the bat.  This is new 
code, so why chain yourself to legacy problems?

A starting place could be the work Trond is doing to replace idmapd.

-- 
chuck[dot]lever[at]oracle[dot]com
