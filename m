From: Sridhar Samudrala <sri@us.ibm.com>
Subject: NFS file locking for clustered filesystems
Date: Tue, 13 Jul 2004 14:32:12 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BkUtP-0001z1-AE
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 14:32:51 -0700
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BkUtO-0006u1-Tr
	for nfs@lists.sourceforge.net; Tue, 13 Jul 2004 14:32:51 -0700
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
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

Hi

I am looking into an issue with locking that is faced by clustered filesystems
with exports to NFS clients. In the current NFS implementation, NFS advisory
locking is performed by lockd on the exporting node. It does local locking even
if the underlying filesystem provides its own locking routine.

There have been earlier attempts to fix this issue and patches were submitted
which called the underlying filesystem locks.  But they have been rejected with
a reason that lockd cannot sleep although the users claim that the underlying
filesytem lock routines do not block.
I was told that there was a suggestion to use workqueues as a way around this
problem. I have been thinking about this and am laying down my initial thoughts
on how we can do this without blocking lockd.  I would appreciate if you can
review and provide any suggestions on how this can be done in a way that is
acceptable for inclusion in mainline kernel.

Currently lockd is implemented as kernel thread that gets and processes
lock requests in a sequential loop. svc_recv() gets the requests and
svc_process() processes them. So blocking in the processing of any particular
request will block all the future calls too.

One simple way to avoid blocking new requests is to have lockd get the request
and schedule the processing of the request to a separate kernel thread. But
creating a new kernel thread or scheduling from a pool of threads for each
request may be expensive.

2.6 provides a workqueue mechanism where we can defer the work to worker
threads. Using this mechanism we can add the "work to process lock request"
to the workqueue and schedule it to be done in the worker threads. But as
i understand workqueues, the work requests are done in the order in which
they are added to the queue and a new work request will not start until the
earlier ones are completed. So basically lockd is not blocked accepting new
requests, but processing of new requests is still blocked by earlier requests.

Do you agree with either of these mechanisms that make lockd multi-threaded?
With these changes, will it be acceptable to call the file-system lock
operations in lockd? If not, please let me know of any other possible solutions
to this issue.

With NFSV4 we do not have lockd and all the locking requests are handled by
nfsd threads. So i hope calling underlying filesystem lock calls is less of
an issue with V4 as there will be multiple nfsd threads.

Thanks
Sridhar



-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
