From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Stale handle error on RHEL4 (2.6.9-22.ELsmp)
Date: Thu, 16 Feb 2006 10:35:51 -0500
Message-ID: <1140104151.8891.38.camel@lade.trondhjem.org>
References: <20060216153400.30128.qmail@web51608.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9lB8-0005XX-3Z
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 07:36:22 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9lB6-0005OK-IM
	for nfs@lists.sourceforge.net; Thu, 16 Feb 2006 07:36:22 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060216153400.30128.qmail@web51608.mail.yahoo.com>
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

On Thu, 2006-02-16 at 07:34 -0800, mehta kiran wrote:
> Hi Trond,
>   partitions /dev/sdi1 and /dev/sdi2 are 
>   seen by both the systems on which server
>   can start and their major/minor numbers
>   are same on both the systems.
>   Sfter server fails over to other system,
>   output of exportfs and mount looks the same.
>   Should /export directory which is exported
>   with fsid=0 be on shared disk as well ?

Probably, yes.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
