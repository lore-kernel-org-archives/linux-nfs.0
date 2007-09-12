From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch] sunrpc: make closing of old temporary sockets
	work	(was: problems with lockd in 2.6.22.6)
Date: Wed, 12 Sep 2007 14:42:22 -0400
Message-ID: <20070912184222.GG4274@fieldses.org>
References: <200709121407.11151.wolfgang.walter@studentenwerk.mhn.de>
	<18151.62510.891210.485277@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Wolfgang Walter <wolfgang.walter@studentenwerk.mhn.de>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IVXAP-0002zN-56
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 11:42:25 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IVXAS-0006jN-No
	for nfs@lists.sourceforge.net; Wed, 12 Sep 2007 11:42:30 -0700
In-Reply-To: <18151.62510.891210.485277@notabene.brown>
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

On Wed, Sep 12, 2007 at 04:14:06PM +0200, Neil Brown wrote:
> So it is in 2.6.21 and later and should probably go to .stable for .21
> and .22.
> 
> Bruce:  for you :-)

OK, thanks!  But, (as is alas often the case) I'm still confused:

>  		if (!test_and_set_bit(SK_OLD, &svsk->sk_flags))
>  			continue;
> -		if (atomic_read(&svsk->sk_inuse) || test_bit(SK_BUSY, &svsk->sk_flags))
> +		if (atomic_read(&svsk->sk_inuse) > 1
> +		    || test_bit(SK_BUSY, &svsk->sk_flags))
>  			continue;
>  		atomic_inc(&svsk->sk_inuse);
>  		list_move(le, &to_be_aged);

What is it that ensures svsk->sk_inuse isn't incremented or SK_BUSY set
after that test?  Not all the code that does either of those is under
the same serv->sv_lock lock that this code is.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
