From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 2.4] (retry) increase NFSSVC_MAXBLKSIZE on large
 page machines
Date: Mon, 26 Jul 2004 13:35:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <410540C7.1050508@RedHat.com>
References: <20040726081439.GE17056@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bp9Ne-0006ci-5b
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 10:35:18 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Bp9Nd-0007X0-On
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 10:35:18 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040726081439.GE17056@sgi.com>
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

Greg Banks wrote:

>I've been out of the loop for a few weeks now so I'm getting back
>in by sending and resending a bunch of patches.
>
>This one (for 2.4 only) was sent twice but has not yet appeared in
>Marcello's BK.
>
>http://marc.theaimsgroup.com/?l=linux-nfs&m=107002386729570&w=2
>http://marc.theaimsgroup.com/?l=linux-kernel&m=108391490102531&w=2
>
>This patch makes NFSSVC_MAXBLKSIZE depend on PAGE_SIZE so that machines
>with large page sizes can take advantage of that feature to serve NFS
>with larger blocksizes, increasing performance and avoiding a fallback
>to synchronous traffic between machines with page sizes greater than 8K.
>Also, documents the actual constraints on NFSSVC_MAXBLKSIZE.
>  
>
I've had people ask about this as well.... It would be good if this made 
in (imho)....

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
