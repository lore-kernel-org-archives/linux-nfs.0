From: trond.myklebust@fys.uio.no
Subject: RE: [PATCH 2.6.3] Add write throttling to NFS client
Date: Mon, 1 Mar 2004 06:50:05 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1060.207.214.87.84.1078120205.squirrel@webmail.uio.no>
References: <20040301043316.69563.qmail@web12822.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>,
     "Charles Lever" <Charles.Lever@netapp.com>,
     "Olaf Kirch" <okir@suse.de>,"Greg Banks" <gnb@melbourne.sgi.com>,
     nfs@lists.sourceforge.net,Shantanu.Goel@lehman.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AxgNl-000878-0N
	for nfs@lists.sourceforge.net; Sun, 29 Feb 2004 21:54:25 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AxgJm-0002V8-R1
	for nfs@lists.sourceforge.net; Sun, 29 Feb 2004 21:50:19 -0800
To: "Shantanu Goel" <sgoel01@yahoo.com>
In-Reply-To: <20040301043316.69563.qmail@web12822.mail.yahoo.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

På su , 29/02/2004 klokka 20:33, skreiv Shantanu Goel:
> I have been experimenting with the RPC scheduler and
> found the changes I am about to describe to be quite
> effective.  A flag has been added to rpc_wait_queue
> called "batch".  This changes the way sleep/wakeup are
> implemented.  When the flag is set, tasks are grouped
> by the id of the initiating process and a batch count
> is set for each process.  The scheduler will keep
> submitting tasks for the same process until the batch
> count goes to zero.  At that point, the scheduler
> switches to another process.  The transport layer uses
> this feature for the backlog queue.  This has the
> following advantages.
>
> - It is independant of the type of request.
> - It prevents any process from completely hogging
> the request slots.
> - It prevents any process from starving completely.
> - It does not require any changes to NFS layer so that
> takes care of layering violations.
> - The # async requests is limited only by the amount
> of memory available.
> - The batching allows large read/write requests to be
> sent back to back.
>
> Patch is attached.
>
> Comments?

Woah.... What's all this struct rpc_pid stuff?

If you need to sort everything by pid (...and I'm not convinced that is
such a great idea) then you can do it by adding 1 extra linked list in the
struct rpc_task to act as the head of the pid list... No need for any
fragile allocation of extra structures from inside
__rpc_add_wait_queue().

The question is, though, why are you sorting stuff by pid? That isn't even
defined for most of the asynchronous requests. As I said before: in a low
memory situation it is silly to be treating a new readdir() or a stat() in
preference to a bunch of queued pdflush or memory allocator requests.
Why not sort them by inode number instead?
...or have well defined priority levels for each type of request (as Chuck
suggested) so that we can schedule them properly. Synchronous requests
already have all the properties that you listed. All you need to do is to
schedule them independently of the asynchronous tasks.

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
