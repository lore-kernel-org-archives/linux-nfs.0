From: "Andrew Theurer" <habanero@us.ibm.com>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Fri, 18 Oct 2002 10:12:12 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <004d01c276bb$39b32980$2a060e09@beavis>
References: <001301c275e6$f31d5970$2a060e09@beavis><20021018.012618.74755132.taka@valinux.co.jp><shs8z0w1f3k.fsf@charged.uio.no> <20021018.161952.41628057.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <neilb@cse.unsw.edu.au>, <davem@redhat.com>,
        <linux-kernel@vger.kernel.org>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mg03.austin.ibm.com ([192.35.232.20])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 182Yyx-0006Bg-00
	for <nfs@lists.sourceforge.net>; Fri, 18 Oct 2002 08:24:11 -0700
To: <trond.myklebust@fys.uio.no>, "Hirokazu Takahashi" <taka@valinux.co.jp>
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

> >      > Congestion avoidance mechanism of NFS clients might cause this
> >      > situation.  I think the congestion window size is not enough
> >      > for high end machines.  You can make the window be larger as a
> >      > test.
> >
> > The congestion avoidance window is supposed to adapt to the bandwidth
> > that is available. Turn congestion avoidance off if you like, but my
> > experience is that doing so tends to seriously degrade performance as
> > the number of timeouts + resends skyrockets.
>
> Yes, you must be right.
>
> But I guess Andrew may use a great machine so that the transfer rate
> has exeeded the maximum size of the congestion avoidance window.
> Can we determin preferable maximum window size dynamically?

Is this a concern on the client only?  I can run a test with just one client
and see if I can saturate the 100Mbit adapter.  If I can, would we need to
make any adjustments then?  FYI, at 115 MB/sec total throughput, that's only
2.875 MB/sec for each of the 40 clients.  For the TCP result of 181 MB/sec,
that's 4.525 MB/sec, IMO, both of which are comfortable throughputs for a
100Mbit client.

Andrew Theurer



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
