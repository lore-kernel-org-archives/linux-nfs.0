From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: md/raid project support?
Date: Fri, 08 Sep 2006 09:22:59 -0400
Message-ID: <1157721779.5690.5.camel@lade.trondhjem.org>
References: <215ff4410609080112x5bdaad34w6c0223cd54fdab80@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GLgKG-0005Ys-SX
	for nfs@lists.sourceforge.net; Fri, 08 Sep 2006 06:23:21 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GLgKF-0008Gs-9K
	for nfs@lists.sourceforge.net; Fri, 08 Sep 2006 06:23:21 -0700
To: Chris Fanning <christopher.fanning@gmail.com>
In-Reply-To: <215ff4410609080112x5bdaad34w6c0223cd54fdab80@mail.gmail.com>
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

On Fri, 2006-09-08 at 10:12 +0200, Chris Fanning wrote:
> Hello all,
> 
> Sorry for the off-topic, but where can is the mail list for md/raid project?
> 
> I've looked about on the web but haven't found anything although I
> have learn't that Mr Neil Brown works on both md and nfs. Thankyou
> Neil.

The place to look for that sort of information is the MAINTAINERS file
at the very top of the kernel source tree.

        SOFTWARE RAID (Multiple Disks) SUPPORT
        P:      Ingo Molnar
        M:      mingo@redhat.com
        P:      Neil Brown
        M:      neilb@cse.unsw.edu.au
        L:      linux-raid@vger.kernel.org
        S:      Maintained

Cheers,
  Trond


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
