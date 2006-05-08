From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Mon, 08 May 2006 13:37:03 -0400
Message-ID: <445F81BF.5080708@RedHat.com>
References: <444EC96B.80400@RedHat.com>	 <17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com>	 <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com>	 <445834CB.4050408@citi.umich.edu> <445B5C2D.5040404@RedHat.com>	 <445B66E6.7030700@redhat.com> <445CB41A.9040400@RedHat.com>	 <445F50AC.1070306@redhat.com> <1147108195.8603.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FdEwu-0001Ky-5a
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 16:15:32 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fd9fe-00062B-4J
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 10:37:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fd9fb-0003L0-SQ
	for nfs@lists.sourceforge.net; Mon, 08 May 2006 10:37:22 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1147108195.8603.2.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



Trond Myklebust wrote:
> No it is not: it uses the full RPC cred as the index.
I concur... I just wrote a test problem and things
work as expected...

steved.


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
