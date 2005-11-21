From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: export very large filesystem
Date: Mon, 21 Nov 2005 09:51:02 -0500
Message-ID: <1132584662.8020.19.camel@lade.trondhjem.org>
References: <4381DDBA.9090509@chrisdos.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EeD13-0008CI-SC
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 06:51:33 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EeD12-000284-1m
	for nfs@lists.sourceforge.net; Mon, 21 Nov 2005 06:51:33 -0800
To: Chris Dos <chris@chrisdos.com>
In-Reply-To: <4381DDBA.9090509@chrisdos.com>
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

On Mon, 2005-11-21 at 07:46 -0700, Chris Dos wrote:
> I have a customer that would like to export their 22.5 TB XFS file system via 
> NFS using Linux 2.6.14.  Before I even attempt to do this, can NFS v2/3/4 even 
> handle something like this?

Yes.



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
