From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS mounts being mounted read-only depending upon
	mount	order???
Date: Mon, 20 Nov 2006 16:43:47 -0500
Message-ID: <1164059027.5723.77.camel@lade.trondhjem.org>
References: <455DFE02.7050801@Cassatt.COM>  <456216CC.40006@Cassatt.COM>
	<1164057026.5723.65.camel@lade.trondhjem.org>
	<45621C87.1050307@Cassatt.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GmGw6-0008LM-Ii
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 13:44:18 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/NsR6IzWnRQTKk8A5qsj4sh902mEIDYms=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GmGw6-0000H8-4R
	for nfs@lists.sourceforge.net; Mon, 20 Nov 2006 13:44:19 -0800
To: Michael Walker <Michael.Walker@Cassatt.COM>
In-Reply-To: <45621C87.1050307@Cassatt.COM>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2006-11-20 at 13:22 -0800, Michael Walker wrote:
> 
> feature - Wow - I'm surprised part of this could be
> integrated without having the full solution put
> together.
> 
> At the moment we have a diskless NFS system setup
> for booting our systems.  We have the root as read-only and other
> mount points mounted read-write (/usr, /var, ...)
> 
> With this feature integrated we have to make sure our read-only
> and our read-write directories are in different physical partitions
> on the server?  Wow - in my mind this is a drastic change
> to integrate without having the full solution present?  Previously
> the only thing we had to worry about on the server was how
> the NFS exports were setup.

There _are_ workarounds available. You can use the 'fsid' export option
to tell knfsd to export the directories as if they were different
filesystems.

For instance if I have

        /export/home	 141.211.133.0/24(rw,sync,no_subtree_check,fsid=0)
        /export/home/trondmy 141.211.133.0/24(rw,sync,no_subtree_check,fsid=3)

in /etc/exports on the server, then I can do

mount -t nfs -oro server:/export/home /mnt/foo
mount -t nfs -orw server:/export/home/trondmy /mnt/bar

with no trouble. From 'cat /proc/mounts'

server:/export/home /mnt/foo nfs rw,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=server 0 0
server:/export/home/trondmy /mnt/bar nfs ro,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,sec=sys,addr=server 0 0

as expected.

> Can you point me to where the required 'mount --bind' fixes are
> being discussed?  I haven't been able to find the
> thread in the 'lkml' (not that it isn't there somewhere).
> 
> Without the matching 'mount --bind' fixes this is a very serious
> regression for us?

I believe the most recent patchsets can be found from

http://marc.theaimsgroup.com/?l=linux-kernel&m=115447687730218&w=2

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
