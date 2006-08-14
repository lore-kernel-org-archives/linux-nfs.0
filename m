From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: Kernel oops (NLM?)
Date: Mon, 14 Aug 2006 10:24:41 -0400
Message-ID: <44E087A9.2000303@redhat.com>
References: <Pine.LNX.4.62.0608140949350.23888@office2.c1.internal>	<44E07FC4.9090707@redhat.com>
	<Pine.LNX.4.62.0608141603520.32349@office2.c1.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCdOA-0005x3-28
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 07:25:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCdO9-0001XN-CB
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 07:25:58 -0700
To: Allard Hoeve <allard@byte.nl>
In-Reply-To: <Pine.LNX.4.62.0608141603520.32349@office2.c1.internal>
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

Allard Hoeve wrote:

>I'm currently unaware of a way to reproduce the oops, sorry. It is a 
>production server under heavy load, so I can't fiddle around much. 
>
Understood. We're going to do some stress tests on NLM too - so don't 
worry about it.

>PS: All clients are configured to use nfsv3. nlm4svc_retrieve_args looks
>     like an NFS4 codepath, doesn't it?
>
>  
>
No - that's an NLM version number, not NFS version number.

-- Wendy



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
