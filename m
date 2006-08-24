From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: NGROUPS limitation on RPCSEC_GSS/krb5?
Date: Thu, 24 Aug 2006 12:03:58 -0400
Message-ID: <1156435438.5629.44.camel@localhost>
References: <20060824141428.GA23025@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GGHgq-0005t6-Sq
	for nfs@lists.sourceforge.net; Thu, 24 Aug 2006 09:04:21 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GGHgl-0003ey-Sp
	for nfs@lists.sourceforge.net; Thu, 24 Aug 2006 09:04:18 -0700
To: Frank van Maarseveen <frankvm@frankvm.com>
In-Reply-To: <20060824141428.GA23025@janus>
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

On Thu, 2006-08-24 at 16:14 +0200, Frank van Maarseveen wrote:
> I got a report from someone that RPCSEC_GSS/krb5 has a limit on the
> number of secondary groups: no more than 32 groups are supported.
> 
> Can anyone confirm this?

<resending from a different account 'cos sourceforge apparently trusts
spamcop these days>

There is no reason why this limitation should exist, so that would have
to be an implementation "bug" in nfsd if true.

Hrmm... The kernel looks OK: the downcall stuff doesn't appear to be
limited.

...Ah. svcgssd appears to be using the NGROUPS macro. If your glibc is
old enough, then I suspect it might be setting that to 32, but at least
in my glibc, then /usr/include/sys/param.h would appear to be setting it
to NGROUPS_MAX, which again appears to evaluate to 65536.

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
