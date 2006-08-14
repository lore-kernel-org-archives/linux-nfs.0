From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: Kernel oops (NLM?)
Date: Mon, 14 Aug 2006 09:51:00 -0400
Message-ID: <44E07FC4.9090707@redhat.com>
References: <Pine.LNX.4.62.0608140949350.23888@office2.c1.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCcrp-0003FR-0m
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 06:52:33 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCcro-0000cU-Ci
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 06:52:33 -0700
To: Allard Hoeve <allard@byte.nl>
In-Reply-To: <Pine.LNX.4.62.0608140949350.23888@office2.c1.internal>
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

>
> Hello all,
>
> Some time ago, I encountered a kernel oops that resulted in a crashed 
> lock daemon. nfsd never stopped working, but all client lock requests 
> stalled. 

 
Are there certain steps we can follow to recreate this issue ?

-- Wendy


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
