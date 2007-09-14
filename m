From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] sunrpc: make closing of old temporary sockets
	work	(was: problems with lockd in 2.6.22.6)
Date: Fri, 14 Sep 2007 10:29:15 -0400
Message-ID: <20070914142915.GE20606@fieldses.org>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de>
	<200709122140.57783.wolfgang.walter@studentenwerk.mhn.de>
	<20070912195512.GC13792@fieldses.org>
	<200709141112.30634.wolfgang.walter@studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, netdev@vger.kernel.org,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	trond.myklebust@fys.uio.no
To: Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWCAq-0007hX-RZ
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 07:29:36 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IWCAt-0006JT-F5
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 07:29:40 -0700
In-Reply-To: <200709141112.30634.wolfgang.walter@studentenwerk.mhn.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, Sep 14, 2007 at 11:12:30AM +0200, Wolfgang Walter wrote:
> Am Mittwoch, 12. September 2007 21:55 schrieb J. Bruce Fields:
> > On Wed, Sep 12, 2007 at 09:40:57PM +0200, Wolfgang Walter wrote:
> > > On Wednesday 12 September 2007, J. Bruce Fields wrote:
> > > > On Wed, Sep 12, 2007 at 04:14:06PM +0200, Neil Brown wrote:
> > > > > So it is in 2.6.21 and later and should probably go to .stable for
> > > > > .21 and .22.
> > > > >
> > > > > Bruce:  for you :-)
> > > >
> > > > OK, thanks!  But, (as is alas often the case) I'm still confused:
> > > > >  		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
> > > > >  			continue;
> > > > > -		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY,
> > > > > &svsk->sk_flags)) +		if (atomic_read(&svsk->sk_inuse) > 1
> > > > > +		    || test_bit(SK_BUSY, &svsk->sk_flags))
> > > > >  			continue;
> > > > >  		atomic_inc(&svsk->sk_inuse);
> > > > >  		list_move(le, &to_be_aged);
> > > >
> > > > What is it that ensures svsk->sk_inuse isn't incremented or SK_BUSY set
> > > > after that test?  Not all the code that does either of those is under
> > > > the same serv->sv_lock lock that this code is.
> > >
> > > This should not matter - SK_CLOSED may be set at any time.
> > >
> > > svc_age_temp_sockets only detaches the socket, sets SK_CLOSED and then
> > > enqueues it. If SK_BUSY is set its already enqueued and svc_sock_enqueue
> > > ensures that it is not enqueued twice.
> >
> > Oh, got it.  And the list manipulation is safe thanks to sv_lock.  Neat,
> > thanks.  Can you verify that this solves your problem?
> 
> Patch works fine here.

Great, thanks again!

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
