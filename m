From: Chris Worley <cworley@lnxi.com>
Subject: RE: Pb of optimization for a Cluster under Gigabit
Date: 07 Apr 2004 15:31:40 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1081373500.2556.16643.camel@localhost>
References: <482A3FA0050D21419C269D13989C61130435DEAA@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBKiN-0003kx-DN
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 14:36:07 -0700
Received: from 208.177.141.226.ptr.us.xo.net ([208.177.141.226] helo=localhost.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBKiM-00040I-T6
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 14:36:06 -0700
To: didier@ece.gatech.edu
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DEAA@lavender-fe.eng.netapp.com>
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

On Wed, 2004-04-07 at 14:58, Lever, Charles wrote:
> > 
> > That definitely helped. Now the NFS options passed
> > via automount to the client are:
> > 
> > rw,nfsvers=3,udp,hard,intr,rsize=8192,wsize=8192
> > 
> > However, the load of the nfs server still goes up to 3.5

Is that option string coming from /proc/mounts, or actually what you're
using?  If it's coming from /proc/mounts, then not all options are
echoed... and, one thing to definitely get the load level up on the
server is using the "noac" option on the clients.



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
