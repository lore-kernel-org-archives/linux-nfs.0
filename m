From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Linux rpcbind daemon doesn't work with v4 GETVERSADDR
	requests
Date: Fri, 17 Aug 2007 06:54:14 -0400
Message-ID: <46C57E56.8080305@RedHat.com>
References: <46C4B41D.6010406@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: chuck.lever@Oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ILzTu-0001lE-Fz
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 03:55:06 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ILzTx-0005W3-Ia
	for nfs@lists.sourceforge.net; Fri, 17 Aug 2007 03:55:10 -0700
In-Reply-To: <46C4B41D.6010406@oracle.com>
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



Chuck Lever wrote:
> Hi Steve-
> 
> I was testing the in-kernel rpcbind client to fix a bug with the 
> GETVERSADDR request... and noticed that the Linux rpcbind client doesn't 
> respond correctly to these requests.  I get a 4-byte zero response 
> instead of the expected 24-byte universal address.
OK... could you please open a bz with all the details on how
to reproduce the problem... I'll try to knock it out asap...

steved.



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
