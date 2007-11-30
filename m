From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Fri, 30 Nov 2007 11:27:16 -0500
Message-ID: <475039E4.5070903@redhat.com>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>	
	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>
	<47434ED7.4010100@redhat.com>	 <47435049.1010800@redhat.com>
	<47445727.5090705@oracle.com>	 <474A3D6B.2060208@redhat.com>
	<20071126050230.GD21120@fieldses.org>	
	<18254.19187.470275.538680@notabene.brown>
	<1196314230.7950.42.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, chuck.lever@oracle.com,
	nfs@lists.sourceforge.net, NeilBrown <neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Iy8ls-0006WB-SD
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 08:31:20 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Iy8ly-0003aM-Gq
	for nfs@lists.sourceforge.net; Fri, 30 Nov 2007 08:31:26 -0800
In-Reply-To: <1196314230.7950.42.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:
> Actually, the real problem would be dealing with something like
> unlink('foo') followed by open('foo', O_CREAT|O_EXCL). How do you ensure
> that a replay of those actions following a reboot is fully consistent in
> the face of some other client attempting an open('foo', O_CREAT) at the
> same time?
>
> The problem is that a number of directory operations involve exclusive
> semantics, and so cannot be replayed. The solution to this sort of
> problem is going to have to involve exclusive (i.e. write) directory
> delegations to ensure that whatever transactions one client performs
> cannot interfere with the transactions performed by another.
>
>   

Well, a dumb question from me (borrowing Bruce's line :) ) ... even with 
"sync" in place, when server rebooted, the RPC reply cache is gone. How 
does linux server handle re-transmitted non-idempotent requests ?

-- Wendy



-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

