From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error 512
Date: Wed, 14 Dec 2005 18:13:06 -0500
Message-ID: <1134601986.13707.12.camel@lade.trondhjem.org>
References: <Pine.LNX.4.62.0512141521150.5180@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emfoc-0001mq-0q
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 15:13:42 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emfoa-0005sP-I8
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 15:13:41 -0800
To: Joshua Baker-LePain <jlb17@duke.edu>
In-Reply-To: <Pine.LNX.4.62.0512141521150.5180@chaos.egr.duke.edu>
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

On Wed, 2005-12-14 at 15:42 -0500, Joshua Baker-LePain wrote:
> I'm still seeing a moderate number of errors like this on clients (both 
> centos-3 and centos-4) connected to my centos-4 servers:
> 
> RPC: error 512 connecting to server $HOSTNAME
> nfs_statfs: statfs error = 512
> 
> associated with mounted FSs becoming unavailable for periods of time (not 
> sure exactly how long, but on the order of 10-15 minutes).  What exactly 
> is error 512, and where does it point me to for the purposes of fixing 
> this?

Error 512 is ERESTARTSYS. It means you interrupted the RPC call...

There is a patch going in to 2.6.16 that will remove that error message.

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
