From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: reduce copying data in svc_udp_recvfrom
Date: Mon, 18 Nov 2002 20:09:21 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021118.200921.130623914.taka@valinux.co.jp>
References: <20021115.131641.98855378.taka@valinux.co.jp>
	<15832.10807.339070.614753@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Djvj-0000Tw-00
	for <nfs@lists.sourceforge.net>; Mon, 18 Nov 2002 03:19:03 -0800
To: neilb@cse.unsw.edu.au
In-Reply-To: <15832.10807.339070.614753@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

> > rqstp->rq_arg.head[0] can use data in a skbuff directly instead of
> > copying the data into xdr when the skbuff is linear.
> > New kNFSd can do it like old kNFSd did.
> > 
> > Is there any problem?
> 
> Only one:-)
> 
> In the case where the skb is nonlinear you skb_free_datagram before
> the port/address are copies into rqstp->rq_addr.

Yes, you're right. Thank you.

> Apart from that, the patch is fine, thanks.
> 
> Here is my version.

Looks fine.


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
