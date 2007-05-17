From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 0/14] A transport switch for knfsd
Date: Wed, 16 May 2007 21:36:48 -0400
Message-ID: <EXNANE0169aZbLAX3cf00000a1f@exnane01.hq.netapp.com>
References: <20070516191821.GF9626@sgi.com>
	<20070516205316.GC18927@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>, Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoUvM-0001iA-R0
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 18:37:07 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoUvN-0007GB-TO
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 18:37:03 -0700
In-Reply-To: <20070516205316.GC18927@fieldses.org>
References: <20070516191821.GF9626@sgi.com>
	<20070516205316.GC18927@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

At 04:53 PM 5/16/2007, J. Bruce Fields wrote:
>On Thu, May 17, 2007 at 05:18:21AM +1000, Greg Banks wrote:
>> will be handled in generic code now.  This makes the task of writing
>> new transport code easier and less prone to breakage.
>
>Are there other conjectured future users besides rdma?

SCTP is certainly something to consider.

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
