From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: query about clnt_create
Date: Wed, 15 Feb 2006 14:13:51 -0500
Message-ID: <1140030832.7888.18.camel@lade.trondhjem.org>
References: <20060215161642.58912.qmail@web51607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kevin Coffman <kwc@citi.umich.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9S6Q-0007ar-73
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 11:14:14 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9S6O-0003Xd-Mp
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 11:14:14 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060215161642.58912.qmail@web51607.mail.yahoo.com>
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

On Wed, 2006-02-15 at 08:16 -0800, mehta kiran wrote:
> Hi Kevin,
>       Sorry for not mentioning this.
>       I do not get any error.
>       Customers can have different settings
>       for NFS daemons.
>       I just want to confirm if
>       clnt_create is a realiable 
>       way  to monitor different 
>       versions of nfsd  running.

The only reasonably reliable way to check for RPC service availability
is to ping it using a NULL rpc call (procedure number == 0 and no
arguments).

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
