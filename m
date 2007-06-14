From: John McCorquodale <mcq@cacr.caltech.edu>
Subject: Re: 100% repeatable NFS v3 client hang
Date: Thu, 14 Jun 2007 10:11:06 -0700
Message-ID: <20070614171106.GA1629@danse.us>
References: <20070614170437.GB1597@danse.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HysqW-0003Ou-9N
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 10:10:59 -0700
Received: from danse-head.cacr.caltech.edu ([131.215.145.66]
	helo=w0.cacr.caltech.edu)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HysqY-0006vS-AO
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 10:10:59 -0700
In-Reply-To: <20070614170437.GB1597@danse.us>
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

> Serial console outputs no information during/after the eat-it condition

Whoops, checked my notes.  This is a lie.  server says nothing on console
during eat-it.  Client says:

server not responding
server not responding
server not responding
OK
OK
server not responding
server not responding
server not responding
server not responding
server not responding
server not responding
server not responding
server not responding
server not responding
(hang)

-mcq

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
