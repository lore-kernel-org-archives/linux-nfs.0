From: Allard Hoeve <allard@byte.nl>
Subject: Re: Kernel oops (NLM?)
Date: Mon, 14 Aug 2006 16:09:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0608141603520.32349@office2.c1.internal>
References: <Pine.LNX.4.62.0608140949350.23888@office2.c1.internal>
	<44E07FC4.9090707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GCd8K-0004dc-3X
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 07:09:36 -0700
Received: from ip-82-94-214-63.ams.byte.nl ([82.94.214.63] helo=smtp.byte.nl)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GCd8J-0004MA-Bx
	for nfs@lists.sourceforge.net; Mon, 14 Aug 2006 07:09:36 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: <44E07FC4.9090707@redhat.com>
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


Hello Wendy,

>> Some time ago, I encountered a kernel oops that resulted in a crashed lock 
>> daemon. nfsd never stopped working, but all client lock requests stalled.

> Are there certain steps we can follow to recreate this issue ?

I'm currently unaware of a way to reproduce the oops, sorry. It is a 
production server under heavy load, so I can't fiddle around much. I was 
actually hoping there was something blindingly obvious you could deduct 
from the voodoo in the oops...

Is there anything I can do to generate more/better logs for you in case 
this occurs again on this system?

PS: All clients are configured to use nfsv3. nlm4svc_retrieve_args looks
     like an NFS4 codepath, doesn't it?

Regards,

Allard Hoeve


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
