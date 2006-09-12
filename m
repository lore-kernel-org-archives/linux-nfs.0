From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfssvc: Address already in use
Date: Tue, 12 Sep 2006 07:09:08 -0400
Message-ID: <1158059348.8386.19.camel@lade.trondhjem.org>
References: <450605F4.1060806@mroot.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GN68q-0006GE-7K
	for nfs@lists.sourceforge.net; Tue, 12 Sep 2006 04:09:24 -0700
Received: from pat.uio.no ([129.240.10.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GN68p-0005mQ-Ky
	for nfs@lists.sourceforge.net; Tue, 12 Sep 2006 04:09:25 -0700
To: Martin Wegner <mailing-lists@mroot.net>
In-Reply-To: <450605F4.1060806@mroot.net>
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

On Tue, 2006-09-12 at 02:57 +0200, Martin Wegner wrote:
> Hello.
> 
> Whenever I try to start a NFS daemon on my Gentoo box here, I get the
> following error in the logfile:
> 
> Sep 12 02:45:01 ares nfsd[17564]: nfssvc: Address already in use

Have you tried looking with 'netstat -p' if some daemon has already
grabbed port 2049? If you have set fixed ports for lockd, you might also
want to check that those ports are free.

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
