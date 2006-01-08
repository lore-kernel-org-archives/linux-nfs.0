From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: NFS performance tuning
Date: Sun, 8 Jan 2006 13:10:00 -0800
Message-ID: <OFFAE75FBD.F10D10DF-ON882570F0.0073C58D-882570F0.0073FC86@us.ibm.com>
References: <1136751734.7849.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Ian Kent <raven@themaw.net>,
	Stephen Carville <stephen@totalflood.com>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Evhns-0005Gq-3r
	for nfs@lists.sourceforge.net; Sun, 08 Jan 2006 13:10:16 -0800
Received: from e5.ny.us.ibm.com ([32.97.182.145])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Evhnq-0007jf-Ip
	for nfs@lists.sourceforge.net; Sun, 08 Jan 2006 13:10:15 -0800
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k08LA8ox016507
	for <nfs@lists.sourceforge.net>; Sun, 8 Jan 2006 16:10:08 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k08LA7Vp076588
	for <nfs@lists.sourceforge.net>; Sun, 8 Jan 2006 16:10:07 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k08LA7Bi019640
	for <nfs@lists.sourceforge.net>; Sun, 8 Jan 2006 16:10:07 -0500
In-Reply-To: <1136751734.7849.1.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

nfs-admin@lists.sourceforge.net wrote on 01/08/2006 12:22:13 PM:

> On Sat, 2006-01-07 at 23:44 -0800, Blake Golliher wrote:
> > The linux nfs client supports, at least, a 64k block transfer size.  I 

> > don't believe it's constrained by transport protocol.
> 
> That is a very recent feature, though. Unless you are using the NFS_ALL
> patches, you will only get 64k block transfer sizes on the very latest
> GIT tarball. ;-)
> 
> Cheers,
>   Trond
> 

But is still constrained by the transport protocol.
Marc.


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
