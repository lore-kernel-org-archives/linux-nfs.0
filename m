From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: rq_arg
Date: Mon, 18 Nov 2002 10:30:12 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15832.9860.894866.360484@notabene.cse.unsw.edu.au>
References: <20021115.130852.26540379.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18DYrz-0000AZ-00
	for <nfs@lists.sourceforge.net>; Sun, 17 Nov 2002 15:30:27 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.204] == wireless-204.wireless.cse.unsw.EDU.AU)
	(for <taka@valinux.co.jp>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Mon, 18 Nov 2002 10:30:14 +1100
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: message from Hirokazu Takahashi on Friday November 15
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

On Friday November 15, taka@valinux.co.jp wrote:
> Hello Neil,
> 
> I found a bug in svc_udp_recvfrom() and fixed it.
> rq_arg.head[0].iov_len and rq_arg.page_len will be set to
> wrong value when length of date is smaller than PAGE_SIZE.

Thanks.  I have added
	rqstp->rq_arg.page_base = 0;
for uniformity with the tcp code.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
