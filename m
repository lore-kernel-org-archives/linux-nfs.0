From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: query about clnt_create
Date: Tue, 21 Feb 2006 08:11:39 -0500
Message-ID: <1140527500.7864.42.camel@lade.trondhjem.org>
References: <20060221083948.5152.qmail@web51601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBXJA-00018A-Q7
	for nfs@lists.sourceforge.net; Tue, 21 Feb 2006 05:12:00 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FBXJ9-0004au-4S
	for nfs@lists.sourceforge.net; Tue, 21 Feb 2006 05:12:00 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060221083948.5152.qmail@web51601.mail.yahoo.com>
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

On Tue, 2006-02-21 at 00:39 -0800, mehta kiran wrote:
> I noticed that clnt_create takes 3.5 min for tcp
> and 1 min for udp protocol by default
> (when taget system in UNREACHABLE). Anyway to modify
> default timeout ? I could see that there are
> functions like clnt_create_timed on  solaris 5.8/5.9
> but not on linux.

'man 3 rpc' and look for the clnt_control() function

Cheers
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
