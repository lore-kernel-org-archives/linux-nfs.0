From: Mark Goodman <mgoodman@CSUA.Berkeley.EDU>
Subject: Re: Oops on flock on NFS3 krb5 mount
Date: Mon, 31 Jan 2005 10:55:43 -0800
Message-ID: <41FE7F2F.209@csua.berkeley.edu>
References: <41F9FB44.9060002@csua.berkeley.edu> <1107029039.11814.32.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvgiI-0006Uj-U9
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 10:55:54 -0800
Received: from soda.csua.berkeley.edu ([128.32.112.233] ident=[h9K9qjfbznAPQjjs7clSBP5hztu/LS7P])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CvgiH-00030D-84
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 10:55:54 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1107029039.11814.32.camel@lade.trondhjem.org>
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

Yes, it fixes it.

Mark

Trond Myklebust wrote:

>Hi Mark,
>
>Does the following patch help? AFAIK, we should not be using RPCSEC_GSS
>against NLM servers if we want to be able to interoperate with other
>implementations.
>
>I've been told that Solaris will, for instance, only use AUTH_SYS for
>locking.
>
>Cheers,
>  Trond  
>  
>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
