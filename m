From: Hirokazu Takahashi <taka@valinux.co.jp>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Sun, 20 Oct 2002 05:34:24 +0900 (JST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021020.053424.41629995.taka@valinux.co.jp>
References: <shs8z0w1f3k.fsf@charged.uio.no>
	<20021018.161952.41628057.taka@valinux.co.jp>
	<004d01c276bb$39b32980$2a060e09@beavis>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, neilb@cse.unsw.edu.au,
	davem@redhat.com, linux-kernel@vger.kernel.org,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sv1.valinux.co.jp ([202.221.173.100])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1830Pu-00037q-00
	for <nfs@lists.sourceforge.net>; Sat, 19 Oct 2002 13:41:50 -0700
To: habanero@us.ibm.com
In-Reply-To: <004d01c276bb$39b32980$2a060e09@beavis>
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

> > Congestion avoidance mechanism of NFS clients might cause this
> > situation.  I think the congestion window size is not enough
> > for high end machines.  You can make the window be larger as a
> > test.

> Is this a concern on the client only?  I can run a test with just one client
> and see if I can saturate the 100Mbit adapter.  If I can, would we need to
> make any adjustments then?  FYI, at 115 MB/sec total throughput, that's only
> 2.875 MB/sec for each of the 40 clients.  For the TCP result of 181 MB/sec,
> that's 4.525 MB/sec, IMO, both of which are comfortable throughputs for a
> 100Mbit client.

I think it's a client issue. NFS servers don't care about cogestion of UDP
traffic and they will try to response to all NFS requests as fast as they can.

You can try to increase the number of clients or the number of mount points
for a test. It's easy to mount the same directory of the server on some
directries of the client so that each of them can work simultaneously.
   # mount -t nfs server:/foo   /baa1
   # mount -t nfs server:/foo   /baa2
   # mount -t nfs server:/foo   /baa3

Thank you,
Hirokazu Takahashi.


-------------------------------------------------------
This sf.net email is sponsored by:
Access Your PC Securely with GoToMyPC. Try Free Now
https://www.gotomypc.com/s/OSND/DD
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
