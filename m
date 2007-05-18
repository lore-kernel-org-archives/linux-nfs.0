From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [RFC,PATCH 4/14] knfsd: has_wspace per transport
Date: Fri, 18 May 2007 09:44:15 -0400
Message-ID: <EXNANE01tUvh18cbKTr00000a35@exnane01.hq.netapp.com>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
	<20070517071202.GE27247@sgi.com>
	<17996.11983.278205.708747@notabene.brown>
	<20070518040509.GC5104@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp2kn-0008SO-6V
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 06:44:21 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp2kq-0005G6-0z
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 06:44:24 -0700
In-Reply-To: <20070518040509.GC5104@sgi.com>
References: <20070516192211.GJ9626@sgi.com>
	<20070516211053.GE18927@fieldses.org>
	<20070517071202.GE27247@sgi.com>
	<17996.11983.278205.708747@notabene.brown>
	<20070518040509.GC5104@sgi.com>
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

At 12:05 AM 5/18/2007, Greg Banks wrote:
>>  Do that mean that RDMA will never
>> reject a write due to lack of space? 
>
>No, it means that the current RDMA send code will block waiting
>for space to become available.  That's right, nfsd threads block on
>the network.  Steel yourself, there's worse to come.

Huh? RDMA Sends never block, except to wait for the handshake as the
hardware picks up the work request.

What's the "worse" part you refer to?

Tom.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
