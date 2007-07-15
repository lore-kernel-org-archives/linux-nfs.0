From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Creating a Load Balanced E-mail Server with NFS
	mounts	with CentOS - how to optimize for performance?
Date: Sat, 14 Jul 2007 21:01:13 -0400
Message-ID: <1184461273.20296.17.camel@heimdal.trondhjem.org>
References: <4698100A.1070702@garlic.com>
	<1184427086.7115.13.camel@heimdal.trondhjem.org>
	<46995E61.4050503@garlic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Patrick - South Valley Internet <patrickm@garlic.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9sU9-0005y6-Lz
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 18:01:24 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/yjl/5x+tHaa8vJD8obbmnK54GvNGl7l4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I9sUB-0000O6-Ol
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 18:01:21 -0700
In-Reply-To: <46995E61.4050503@garlic.com>
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

On Sat, 2007-07-14 at 16:38 -0700, Patrick - South Valley Internet
wrote:

> 2) I'm not sure if I am using TCP or UDP - how do I check?

'cat /proc/mounts' should tell you.

> 3) I do not have any iptables set up - should I?

That's fine. I'd advise against setting anything up until you are
satisfied the iptables-less setup works.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
