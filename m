From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: query about clnt_create
Date: Tue, 21 Feb 2006 08:42:20 -0500
Message-ID: <1140529340.7864.55.camel@lade.trondhjem.org>
References: <20060221131540.24078.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FBXmq-0005Bv-98
	for nfs@lists.sourceforge.net; Tue, 21 Feb 2006 05:42:40 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FBXmo-0005VM-TO
	for nfs@lists.sourceforge.net; Tue, 21 Feb 2006 05:42:40 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20060221131540.24078.qmail@web51602.mail.yahoo.com>
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

On Tue, 2006-02-21 at 05:15 -0800, mehta kiran wrote:
> Hi Trond,
>   perhaps i was not clear.
>   I am talking about timeout for clnt_create
>   and not about clnt_call which already has
>   client handle in place. clnt_control will act on 
>   client handle and i am searching for something which
> 
>   will create client handle within specified timeout 
>   if possible.

AFAICS clnt_create() will only do RPC calls if you fail to specify the
port number to connect to, in which case it needs to call pmap_getport.

The portmapper timeout values appear to be hardcoded into the glibc rpc
code, but writing your own client for PMAP_GETPORT should be trivial.

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
