From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: NFS as a Cluster File System.
Date: Tue, 14 Jan 2003 08:01:33 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E07D551E9@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lorn Kay <lorn_kay@hotmail.com>, nfs@lists.sourceforge.net,
   linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YTVl-0002Lk-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 08:01:57 -0800
To: "'Neil Brown'" <neilb@cse.unsw.edu.au>, Alan Robertson <alanr@unix.sh>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> On Thursday January 9, alanr@unix.sh wrote:
> > 
> > NFS V3 and before have problems with "cache coherency".  
> That is, the
> > different nodes in the cluster are not guaranteed to see 
> the same contents.
> > 
> > I think this is supposed to be fixed in v4.
> > 
> 
> NFSv4 does not try to "fix" this.  It makes no attempts at 
> "cache coherency" beyond what NFSv2/3 provide which is "close 
> to open" cohenrence, meaning that if only one process has a 
> file open at a time, then everythnig will appear coherent, 
> and if multiple processes have the file open at the same 
> time, they need to use record locking.

well, coherency is partially addressed in NFSv4 with delegations.
a server can delegate a file to a client, allowing the client
to cache the file and trust that the server will notify it when
another client wants to access the file (read or write).

for an aggressively shared file, this doesn't perform well, but
NFS has always assumed that there is little concurrent sharing
of files.

this paradigm probably doesn't fit well with typical file
usage in clusters, where files are very very large, and many
nodes may be working on independent pieces of the same file
at the same time.  in that case, record locking might be
best.  however, on Linux, the client purges the entire file
from its cache when a file is locked, rather than just the
areas that were byte-range locked.


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
