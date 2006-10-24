From: Eric Sandeen <sandeen@sandeen.net>
Subject: Re: kernel panic after upgrading to 2.6
Date: Tue, 24 Oct 2006 12:11:43 -0500
Message-ID: <453E494F.8080808@sandeen.net>
References: <Pine.LNX.4.58.0610240938400.8370@lewis.et.byu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, xfs@oss.sgi.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GcPos-00016p-UQ
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 10:12:07 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GcPok-0004l4-L1
	for nfs@lists.sourceforge.net; Tue, 24 Oct 2006 10:12:02 -0700
To: David Dougall <davidd@et.byu.edu>
In-Reply-To: <Pine.LNX.4.58.0610240938400.8370@lewis.et.byu.edu>
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

David Dougall wrote:
> I am running kernel 2.6.18 after trying 2.6.17.6 and 2.6.17.13 with
> similar results.  I continue to have nfs servers kernel panic on a very
> regular basis, every few days.  Sometimes I need to do an xfs_repair to
> get the filesystem to remount.  I got the following kernel panic message
> from the syslog this time:
> Message from syslogd@nfs09 at Tue Oct 24 09:35:14 2006 ...
> nfs09 kernel: Oops: 0000 [#1]

If you ran 2.6.17 < 2.6.17.7, there was a bug:

http://oss.sgi.com/projects/xfs/faq.html#dir2

I would suggest getting xfsprogs v. 2.8.10 or newer, as referenced in
the faq, repair your filesystem, and see if the problem is resolved.

-Eric


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
