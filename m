From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: NFS as a Cluster File System.
Date: 10 Jan 2003 03:34:53 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1042169692.28469.33.camel@irongate.swansea.linux.org.uk>
References: <F43H06Ym8Es5FEnoLH80000317f@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: lmb@suse.de, nfs@lists.sourceforge.net, linux-ha@muc.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pc2-cwma1-4-cust86.swan.cable.ntl.com ([213.105.254.86] helo=irongate.swansea.linux.org.uk)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18WpEj-0000yK-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 18:49:33 -0800
To: Lorn Kay <lorn_kay@hotmail.com>
In-Reply-To: <F43H06Ym8Es5FEnoLH80000317f@hotmail.com>
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

On Thu, 2003-01-09 at 23:13, Lorn Kay wrote:
> Sorry, still confused about what a "CFS" really is. In "In Search Of 
> Clusters" Gregory Pfister takes the position that a distributed file system 
> is what he calls a valid "single system image" file system, what I would 
> take to mean a cluster file system (though he doesn't use those words).
> 
> I guess you are saying a clustered file system isn't necessarily supporting 
> a cluster of application servers but is itself stored on a cluster. (A 
> single server can be the only server using a cluster file system.) ?

It seems to mean about three different things 

1.   "A clusterwide view of the file store implemented by any unspecified
means"  - ie an application view point.

2.   "A filesystem which supports operation of a cluster"

3.   "A filesystem with multiple systems accessing a single shared 
file system on shared storage"

Meaning #3 can be really confusing because a 'cluster file system' in that
sense is actually exactly what you don't want for many cluster setups,
especially those with little active shared storage'

[For example if you are doing database failover you can do I/O fencing
 and mount/umount of a more normal fs]




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
