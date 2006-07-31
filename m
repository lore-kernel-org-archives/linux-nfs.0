From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Mon, 31 Jul 2006 11:02:24 +1000
Message-ID: <17613.22176.375521.692211@cse.unsw.edu.au>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
	<1153816400.21040.153.camel@hole.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7MBD-0005W8-Ri
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 18:02:47 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G7MBD-0005HC-Ne
	for nfs@lists.sourceforge.net; Sun, 30 Jul 2006 18:02:48 -0700
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: message from Greg Banks on Tuesday July 25
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tuesday July 25, gnb@melbourne.sgi.com wrote:
> 
> Ok, here are some (12 month old) numbers.  Test is an Altix A350
> server, IRIX NFS clients mounting over TCP, 32K rsize, streaming
> reads from separate files.  N is the number of NICs in the server,
> the number of CPUs in the server, and the number of clients
> (all 3 increased together).  The number of NUMA nodes is N/2.
> 
> N	Throughput, MiB/s	CPU usage, % (max=N*100)
> 	Before	After		Before	After
> ---	------	----		-----	-----
> 4	312	435		350	228
> 6	500	656		501	418
> 8	562	804		690	589
> 

Thanks.  I like to see numbers.  These look good!

> > 
> > Feeling a little uneasy that the rule
> >  must call svc_sock_enqueue after clearing SK_BUSY
> > is not being obeyed....  
> 
> It's a bogus rule.  That comment doesn't really describe
> the way SK_BUSY works at all.
> 

I'm not convinced.

If someone clears SK_BUSY outside of the spinlock (which hardly exists
any more), then they need to make sure svc_sock_enqueue gets called,
otherwise the socket might get lost with no-one to care about it.

With the code as it stands, suppose the wspace callback
(svc_write_space) gets called on a different node immediately after
svc_sock_enqueue has checked with svc_sock_wspace and found there
wasn't enough space.
svc_write_space calls svc_sock_enqueue and finds SK_BUSY set, and so
leaves it alone.  then the original svc_sock_enqueue clears SK_BUSY
and leaves the socket alone.  It should be queued at this point, but
it isn't.

Now I suspect that another svc_write_space call will come along in a
little while and move things along as SOCK_NOSPACE is still set, but
I'm a little concerned about it anyway.

Maybe we can move the test_and_set of SK_BUSY to after the space
test.... but are there atomicity issues with the space test .... maybe
we need to test space before and after grabbing SK_BUSY.... needs more
thought I think.

> > 
> >  kmalloc + memset == kzalloc. Fixed.
> >    I also took the assignment out of the if and removed
> >    the unnecessary cast.
> 
> Sure.  Wouldn't kcalloc() be a better fit?
> 
Yes, I made that change.


> I just noticed there's also a bogus comment added, can you
> please apply this incremental patch?

Sorry, forgot that (I've just sent them to Andrew:-().  
I'll make sure it gets through at some point.

> 
> 
> > > 007 knfsd: add svc_get
> > 
> > Yes... using nr_threads as a pseudo ref count really stinks.
> > I wonder if we can make that go away.  Maybe have a 
> > refcount separate from nr_threads, and nr_thread != 0 
> > causes a refcount of 1...
> 
> Or just rename it sv_refcount and stop pretending it means
> something else?  It seems silly to have two variables which
> are almost exactly the same number, and where the difference
> doesn't matter  (IIRC the only places it's actually used as
> "number of threads" is for estimating upper bounds on socket
> buffer space which is already pretty approximate).

It it also used by svc_set_num_threads, where we subtract 1 before
using it.

Maybe it isn't worth worrying about...

> 
> > You remove a comment that you had previously added.  Why?
> >   -- not fixed pending explanation...
> 
> Umm...where?

Sorry.  You had added a comment, not removed one.  It still was
out-of-context for that patch.  I moved it to the previous patch.
It was this.

@@ -69,7 +90,7 @@ svc_create(struct svc_program *prog, uns
 }
 
 /*
- * Destroy an RPC service
+ * Destroy an RPC service.  Should be called with the BKL held
  */
 void
 svc_destroy(struct svc_serv *serv)


Thanks,
NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
