From: Andrew Theurer <habanero@us.ibm.com>
Subject: Re: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Tue, 22 Oct 2002 16:16:23 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210221616.23282.habanero@us.ibm.com>
References: <shs8z0w1f3k.fsf@charged.uio.no> <004d01c276bb$39b32980$2a060e09@beavis> <20021020.053424.41629995.taka@valinux.co.jp>
Reply-To: habanero@us.ibm.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: trond.myklebust@fys.uio.no, neilb@cse.unsw.edu.au, davem@redhat.com,
        linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mg01.austin.ibm.com ([192.35.232.18])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1846Nz-000837-00
	for <nfs@lists.sourceforge.net>; Tue, 22 Oct 2002 14:16:23 -0700
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20021020.053424.41629995.taka@valinux.co.jp>
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

On Saturday 19 October 2002 15:34, Hirokazu Takahashi wrote:
> Hello,
>
> > > Congestion avoidance mechanism of NFS clients might cause this
> > > situation.  I think the congestion window size is not enough
> > > for high end machines.  You can make the window be larger as a
> > > test.
> >
> > Is this a concern on the client only?  I can run a test with just one
> > client and see if I can saturate the 100Mbit adapter.  If I can, woul=
d we
> > need to make any adjustments then?  FYI, at 115 MB/sec total throughp=
ut,
> > that's only 2.875 MB/sec for each of the 40 clients.  For the TCP res=
ult
> > of 181 MB/sec, that's 4.525 MB/sec, IMO, both of which are comfortabl=
e
> > throughputs for a 100Mbit client.
>
> I think it's a client issue. NFS servers don't care about cogestion of =
UDP
> traffic and they will try to response to all NFS requests as fast as th=
ey
> can.
>
> You can try to increase the number of clients or the number of mount po=
ints
> for a test. It's easy to mount the same directory of the server on some
> directries of the client so that each of them can work simultaneously.
>    # mount -t nfs server:/foo   /baa1
>    # mount -t nfs server:/foo   /baa2
>    # mount -t nfs server:/foo   /baa3

I don't think it is a client congestion issue at this point.  I can run t=
he=20
test with just one client on UDP and achieve 11.2 MB/sec with just one mo=
unt=20
point.  The client has 100 Mbit Ethernet, so should be the upper limit (o=
r=20
really close).  In the 40 client read test, I have only achieved 2.875 MB=
/sec=20
per client.  That and the fact that there are never more than 2 nfsd thre=
ads=20
in a run state at one time (for UDP only) leads me to believe there is st=
ill=20
a scaling problem on the server for UDP.  I will continue to run the test=
 and=20
poke a prod around.  Hopefully something will jump out at me.  Thanks for=
 all=20
the input!

Andrew Theurer


-------------------------------------------------------
This sf.net emial is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ad.doubleclick.net/clk;4699841;7576301;v?http://www.sun.com/javavote
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
