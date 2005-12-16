From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: kernel 2.4  The process hang on NFS
Date: Fri, 16 Dec 2005 02:25:23 -0500
Message-ID: <1134717923.3699.5.camel@lade.trondhjem.org>
References: <20051215195925.475aee2c.s-sagawa@jp.fujitsu.com>
	 <1134655845.7954.4.camel@lade.trondhjem.org>
	 <20051216154055.7f369762.s-sagawa@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1En9ya-00089s-Oh
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 23:26:00 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1En9yZ-0000Ax-4Y
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 23:26:00 -0800
To: Shunichi Sagawa <s-sagawa@jp.fujitsu.com>
In-Reply-To: <20051216154055.7f369762.s-sagawa@jp.fujitsu.com>
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

On Fri, 2005-12-16 at 15:40 +0900, Shunichi Sagawa wrote:
> Do you have a plan to fix this problem on kernel 2.4?
> And, in kernel 2.4, only have to change __wait_event()           
> to wait_event_interruptible() ?

No. 2.4 kernels have been frozen for over a year. Only critical fixes
will be pushed upstream to Marcelo.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
