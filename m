From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: NFS file locking for clustered filesystems
Date: Tue, 10 Aug 2004 17:15:54 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0408101139260.11489@localhost.localdomain>
References: <Pine.LNX.4.58.0407131427580.6626@localhost.localdomain>
 <20040802105103.GJ25023@suse.de> <1091461098.3980.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BugnL-0004kk-B8
	for nfs@lists.sourceforge.net; Tue, 10 Aug 2004 17:16:43 -0700
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BugnK-0005Ny-Uq
	for nfs@lists.sourceforge.net; Tue, 10 Aug 2004 17:16:43 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1091461098.3980.22.camel@lade.trondhjem.org>
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

Olaf, Trond,

Thanks for your responses.

I gathered the following from your suggestions to make the cluster filesyst=
em
process the lock/unlock calls asynchronously,

NLM LOCK/UNLOCK Call on a file in a cluster filesystem exported from an NFS
server will always respond with NLM LOCK/UNLOCK Reply with NLM_BLOCKED as t=
he
status.

Once the cluster filesystem is done granting or denying the lock, the serve=
r
will send a NLM GRANTED_MSG/GRANTED_RES callbacks with the appropriate stat=
us.

Is this correct?

As Olaf suggested, can't we use the existing fl_notify callback instead of
setting up a new callback?

Thanks
Sridhar

On Mon, 2 Aug 2004, Trond Myklebust wrote:

> P=E5 m=E5 , 02/08/2004 klokka 03:51, skreiv Olaf Kirch:
> > On Tue, Jul 13, 2004 at 02:32:12PM -0700, Sridhar Samudrala wrote:
> > > One simple way to avoid blocking new requests is to have lockd get th=
e request
> > > and schedule the processing of the request to a separate kernel threa=
d. But
> > > creating a new kernel thread or scheduling from a pool of threads for=
 each
> > > request may be expensive.
> >
> > I think making lockd multithreaded and whatnot is going to be very
> > painful.
>
> I agree: I was thinking about this at the recent Redhat cluster
> filesystem summit.
>
> What we really want is an interface for asynchronous lock calls in which
> lockd gets called back once the cluster filesystem is ready with the
> results. This is pretty close to what we do already w.r.t. local locks.
>
> IOW for each cluster filesystem we want to set up something like
>
>   typedef void (*lock_callback_t)(struct file_lock fl, int result);
>   int lock(struct file filp, struct file_lock fl, lock_callback_t callbac=
k);
>
> lockd would then call lock() would return immediately once the
> filesystem has set up whatever it needs to do an asynchronous call (it's
> up to the filesystem implementation to decide if that has to involve
> forking off a thread).
> Once the filesystem is done granting or denying the lock, the filesystem
> would use the callback method to notify lockd about the result.
>
> Cheers,
>   Trond
>
>


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
