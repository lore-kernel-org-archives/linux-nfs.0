From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: disabling caching
Date: Fri, 14 Jul 2006 11:26:12 +0200
Message-ID: <20060714092612.GA11555@janus>
References: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1JwD-0006Ud-Us
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 02:26:22 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1JwC-0000wf-Vv
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 02:26:22 -0700
To: Stefan Palme <kleiner@hora-obscura.de>
In-Reply-To: <1152864752.28625.30.camel@devel.office.ancoso-development.de>
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

On Fri, Jul 14, 2006 at 10:12:32AM +0200, Stefan Palme wrote:
> 
> After a few seconds, the open() call on the second box succeeds.
> So I guess that caching is the reason for the second open()-call
> to fail.

You might want to try (1) and/or ((2) or (3)) on the NFS client:

(1)	On the NFS client, put this before the open():

		close(open("whatever", O_WRONLY|O_CREAT, 0666));
		unlink("whatever");

(2)	Try the "noac" nfs mount option, it'll cost performance though.

(3)	Another solution might be to use the patch at www.frankvm.com/nfs-noac
	to selectively disable attribute caching (see the README). It's a trick
	I use for some distributed work.


-- 
Frank


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
