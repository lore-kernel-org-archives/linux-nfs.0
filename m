From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS file locking for clustered filesystems
Date: Mon, 02 Aug 2004 08:38:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1091461098.3980.22.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
	 <20040802105103.GJ25023@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Sridhar Samudrala <sri@us.ibm.com>, nfsv4@linux-nfs.org,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BreuV-0001Se-PI
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 08:39:35 -0700
Received: from adsl-207-214-87-84.dsl.snfc21.pacbell.net ([207.214.87.84] helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.34)
	id 1BreuV-0002Ee-4Y
	for nfs@lists.sourceforge.net; Mon, 02 Aug 2004 08:39:35 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040802105103.GJ25023@suse.de>
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

P=E5 m=E5 , 02/08/2004 klokka 03:51, skreiv Olaf Kirch:
> On Tue, Jul 13, 2004 at 02:32:12PM -0700, Sridhar Samudrala wrote:
> > One simple way to avoid blocking new requests is to have lockd get the =
request
> > and schedule the processing of the request to a separate kernel thread.=
 But
> > creating a new kernel thread or scheduling from a pool of threads for e=
ach
> > request may be expensive.
>=20
> I think making lockd multithreaded and whatnot is going to be very
> painful.

I agree: I was thinking about this at the recent Redhat cluster
filesystem summit.

What we really want is an interface for asynchronous lock calls in which
lockd gets called back once the cluster filesystem is ready with the
results. This is pretty close to what we do already w.r.t. local locks.

IOW for each cluster filesystem we want to set up something like

  typedef void (*lock_callback_t)(struct file_lock fl, int result);
  int lock(struct file filp, struct file_lock fl, lock_callback_t callback)=
;

lockd would then call lock() would return immediately once the
filesystem has set up whatever it needs to do an asynchronous call (it's
up to the filesystem implementation to decide if that has to involve
forking off a thread).
Once the filesystem is done granting or denying the lock, the filesystem
would use the callback method to notify lockd about the result.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
