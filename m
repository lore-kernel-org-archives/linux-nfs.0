From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Pb of optimization for a Cluster under Gigabit
Date: Wed, 07 Apr 2004 15:28:44 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4073918C.7C13AC97@melbourne.sgi.com>
References: <40737404.7000401@ece.gatech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BB5cW-0006Pi-TT
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 22:29:04 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BB5cW-0004V8-MZ
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 22:29:04 -0700
To: Didier CONTIS <didier@ece.gatech.edu>
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

Didier CONTIS wrote:
> 
> All the filesystem are exported with sync and mounted
> on the client (via autofs) with:
> rw,sync,hard,intr,rsize=8192,wsize=8192
> [...]
> Would anyone have any suggestions or recommendations ? [...]

Try removing "sync" from your mount options.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
