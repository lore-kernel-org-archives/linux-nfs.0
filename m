From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS over TCP: random drop
Date: Tue, 16 Mar 2004 20:42:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040316194224.GA3262@suse.de>
References: <482A3FA0050D21419C269D13989C61130435DD6E@lavender-fe.eng.netapp.com> <1079456730.3045.47.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Charles Lever <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3KSM-0008KI-1P
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 11:42:30 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B3KSI-0005sd-Qp
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 11:42:27 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1079456730.3045.47.camel@lade.trondhjem.org>
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

On Tue, Mar 16, 2004 at 12:05:30PM -0500, Trond Myklebust wrote:
> However if the server disconnects us *while we are reconnecting*, then
> the soft request will fail with an EIO. This seems like sensible
> behaviour to me: a server which is accepting a connection then
> immediately breaking it is fundamentally broken...

But the Linux nfsd seems to be doing exactly this - it accepts the
connection, then randomly drops either the oldest or the newest one
(in terms of activity). The one at the head of the queue happens to be
the one we just accepted.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
