From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 000 of 11] knfsd: NUMAisation
Date: Mon, 31 Jul 2006 20:33:41 +1000
Message-ID: <1154342020.21040.2040.camel@hole.melbourne.sgi.com>
References: <1153805274.21040.38.camel@hole.melbourne.sgi.com>
	<17605.50325.842862.8823@cse.unsw.edu.au>
	<1153816400.21040.153.camel@hole.melbourne.sgi.com>
	<17613.22176.375521.692211@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7V5n-0001AK-1n
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 03:33:47 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7V5n-0007nD-9x
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 03:33:47 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17613.22176.375521.692211@cse.unsw.edu.au>
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

On Mon, 2006-07-31 at 11:02, Neil Brown wrote:
> On Tuesday July 25, gnb@melbourne.sgi.com wrote:
> > > 
> > > Feeling a little uneasy that the rule
> > >  must call svc_sock_enqueue after clearing SK_BUSY
> > > is not being obeyed....  
> > 
> > It's a bogus rule.  That comment doesn't really describe
> > the way SK_BUSY works at all.
> > 
> 
> I'm not convinced.
> 
> If someone clears SK_BUSY outside of the spinlock (which hardly exists
> any more), then they need to make sure svc_sock_enqueue gets called,
> otherwise the socket might get lost with no-one to care about it.
> 
> With the code as it stands, suppose the wspace callback
> (svc_write_space) gets called on a different node immediately after
> svc_sock_enqueue has checked with svc_sock_wspace and found there
> wasn't enough space.
> svc_write_space calls svc_sock_enqueue and finds SK_BUSY set, and so
> leaves it alone.  then the original svc_sock_enqueue clears SK_BUSY
> and leaves the socket alone.  It should be queued at this point, but
> it isn't.

Agreed, this could happen.

> Now I suspect that another svc_write_space call will come along in a
> little while 

Or another incoming call.

> and move things along as SOCK_NOSPACE is still set, but
> I'm a little concerned about it anyway.
> 
> Maybe we can move the test_and_set of SK_BUSY to after the space
> test.... but are there atomicity issues with the space test 

I think atomicity issues already existed: in the old code
SK_CLOSE or svc_sock_wspace() could be changed without owning
sv_lock, if the TCP code runs on another CPU.  I suspect this
had no real-world impact because, as you point out, another
attempt to enqueue happens shortly afterward.

> .... maybe
> we need to test space before and after grabbing SK_BUSY.... needs more
> thought I think.

The only useful thing I can think of is (yuck) adding a spinlock
in svc_sock to synchronize both the wspace check and the SK_BUSY
check together.  At least it wouldn't be global.

> > > Yes... using nr_threads as a pseudo ref count really stinks.
> [...]
> Maybe it isn't worth worrying about...

Maybe ;-)

> > > You remove a comment that you had previously added.  Why?
> > >   -- not fixed pending explanation...
> > 
> > Umm...where?
> 
> Sorry.  You had added a comment, not removed one.  It still was
> out-of-context for that patch.  I moved it to the previous patch.
> It was this.
> 
> @@ -69,7 +90,7 @@ svc_create(struct svc_program *prog, uns
>  }
>  
>  /*
> - * Destroy an RPC service
> + * Destroy an RPC service.  Should be called with the BKL held
>   */
>  void
>  svc_destroy(struct svc_serv *serv)

I believe the comment is correct both for the old and new
code, and should stand.  Also, I don't think I deleted it;
I reworded a very similar comment:

gnb@chook 1949> grep '^[-+].*Destroy an RPC' patches/knfsd*

patches/knfsd-add-svc-get:- * Destroy an RPC service
patches/knfsd-add-svc-get:+ * Destroy an RPC service.  Should be called with the BKL held
                                             ^^^^^^^

patches/knfsd-split-svc-serv-into-pools:- * Destroy an RPC server thread
                                                           ^^^^^^^^^^^^^


Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
