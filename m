From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS Client  port
Date: Thu, 15 Dec 2005 22:47:50 -0500
Message-ID: <1134704870.8013.4.camel@lade.trondhjem.org>
References: <20051216023147.51739.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: cel@citi.umich.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1En6Zm-00023k-O9
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 19:48:10 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1En6Zl-0008In-Aj
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 19:48:10 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20051216023147.51739.qmail@web51602.mail.yahoo.com>
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

On Thu, 2005-12-15 at 18:31 -0800, mehta kiran wrote:
> Hi,
>     Any specific reason to make NFS Client connect on 
>     the same port or is it to make it simialr
> to/follow 
>     Solaris implementation where NFS Client connects
> with
>     same port?

Most NFSv2/v3 server implementations expect that if the client wants to
resend an RPC request, then it will use the same port as the original
request. If not, replaying something like a mkdir request would result
in the server returning the equivalent of the error EEXIST.

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
