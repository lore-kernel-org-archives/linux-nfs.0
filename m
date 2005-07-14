From: Peter Staubach <staubach@redhat.com>
Subject: Re: statd for NFSv4 does not create file
Date: Thu, 14 Jul 2005 09:36:52 -0400
Message-ID: <42D66A74.8090205@redhat.com>
References: <20050714133019.30046.qmail@web51613.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt3v0-0008Go-3b
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 06:38:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Dt3uy-0006cR-Pz
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 06:38:26 -0700
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050714133019.30046.qmail@web51613.mail.yahoo.com>
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

mehta kiran wrote:

>Hi Trond , 
>     Lock recovery worked with nfsv3 even if
>     nfs server fail over to some other system
>     This was possible because sm directory was shared
>     across systems.
>     Will this work with nfsv4 though there are
>     no files in sm directory. 
>

Yes, this should work.  NFSv4 will discover that the server has 
"rebooted" using
its mechanism and recover its locks.  The NFSv2 and NVFSv3 clients will 
discover
that the server has "rebooted" using the statd support and recover locks 
as well.

NFSv4 uses a different mechanism than NFSv2 and NFSv3, but if the failover
support was architected correctly, then things should continue to work.  You
may need to look at failover times perhaps.

       ps


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
