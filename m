From: Nicolas Beaulieu <gulliver@condorito.org>
Subject: Re: 2.4.19, Tyan Tiger, Dual Athlon, diskless nodes, rootnfs
 and fsck.ext2 problems
Date: Mon, 7 Oct 2002 10:15:51 +0500 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GSO.4.10.10210071009030.9397-100000@condorito.org>
References: <Pine.LNX.4.44.0210071149530.8881-100000@kenzo.iwr.uni-heidelberg.de>
Reply-To: Nicolas Beaulieu <gulliver@condorito.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: NFS list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from derive.ecn.ulaval.ca ([132.203.59.17] helo=condorito.org)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17yYdg-0001ZO-00
	for <nfs@lists.sourceforge.net>; Mon, 07 Oct 2002 07:13:40 -0700
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0210071149530.8881-100000@kenzo.iwr.uni-heidelberg.de>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Mon, 7 Oct 2002, Bogdan Costescu wrote:

> Date: Mon, 7 Oct 2002 11:52:19 +0200 (CEST)
> From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
> To: Nicolas Beaulieu <gulliver@condorito.org>
> Cc: NFS list <nfs@lists.sourceforge.net>
> Subject: Re: [NFS] 2.4.19, Tyan Tiger, Dual Athlon, diskless nodes,
     rootnfs and fsck.ext2 problems
> 
> On Sat, 5 Oct 2002, Nicolas Beaulieu wrote:
> 
> > ******************
> > 
> > Checking root filesystem
> > 
> > fsck.ext2: Is a directory while trying to open / 
> > /:
> 
> Could you try adding to /etc/fstab on the node something like:
> 
> 192.168.0.1:/client/192.168.0.x 	/	nfs	noauto	0 0
> 
> The "noauto" part is important to prevent re-mounting by the start-up 
> scripts.


Thanks, that was the problem.  


But why does my former config scheme work with 2.4.18 and not with 2.4.19?
Is there a different approach in NFS support from one version to another?
I mean, the start-up scritps you're talking about are the same for both 
versions of the kernel.  There is no other explanation but some subtleties
between 2.4.18 and 2.4.19 NFS support.... isn't it ?


nb 

________________
Nicolas Beaulieu
Departement d'economique et CIRPEE      
Universite Laval, Canada
http://www.condorito.org        
_________________           







-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
