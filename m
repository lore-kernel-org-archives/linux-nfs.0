From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Fri, 18 May 2007 10:30:37 +1000
Message-ID: <17996.62381.294593.115151@notabene.brown>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
	<20070517071202.GE27247@sgi.com>
	<17996.11983.278205.708747@notabene.brown>
	<EXNANE01SlSt7IZfSp100000a27@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoqMo-000566-Ju
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 17:30:46 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoqMq-0004KE-6g
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 17:30:49 -0700
In-Reply-To: message from Talpey, Thomas on Thursday May 17
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

On Thursday May 17, Thomas.Talpey@netapp.com wrote:
> At 06:30 AM 5/17/2007, Neil Brown wrote:
> >And I gather by the fact that you test "->sko_has_wspace" that RDMA
> >doesn't have such a function?  Do that mean that RDMA will never
> >reject a write due to lack of space?  That seems unlikely.
> 
> RDMA uses credits, which are preallocated per-connection resources in
> the hardware. RDMA transports don't generally support flow control, that
> is left to the upper layer. As such, if the client is obeying the protocol, the
> send will succeed. And if it's not, then the client only loses since the failure
> will cause the connection to be lost.
> 
> Someday we might want to support this kind of test. There are shared
> resource schemes in RDMA, more for the receive side, but it's not out of the
> question for sends. As a default though, a NULL has_wspace makes sense. 

Thanks for the explanation.
So presumably the serve communicates to the client how much buffer
space it has via these credits, so that we can be sure a write will
never fail (as long as the protocol is being honoured).  That sounds
reasonable.

I think I would rather
   int rdma_has_wspace(struct svc_sock *svsk) { return 1; }
than NULL.  It removes special cases in the generic code, and gives an
obvious place for a comment explaining that RDMA doesn't need flow
control because it uses credits.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
