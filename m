From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS admin for Linux
Date: Fri, 02 Apr 2004 11:31:54 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1080923514.2782.10.camel@lade.trondhjem.org>
References: <200404021759.38269.frederic.jolly@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9RaL-0001WZ-GC
	for nfs@lists.sourceforge.net; Fri, 02 Apr 2004 08:32:01 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B9RaL-00073V-43
	for nfs@lists.sourceforge.net; Fri, 02 Apr 2004 08:32:01 -0800
To: Jolly Frederic <frederic.jolly@ext.bull.net>
In-Reply-To: <200404021759.38269.frederic.jolly@ext.bull.net>
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

On Fri, 2004-04-02 at 10:59, Jolly Frederic wrote:
> Hello.
> 
> I'm going to work on adminstration tools of NFS and NFSv4 for Linux.
> 
> First of all, I'd like to know if the commands showmount and nfsstat have been 
> updated for NFSv4? Are there people currently working on them?

Showmount isn't really needed for NFSv4: you can (and usually will)
always mount "/". All the exported directories will then appear as
subdirectories of this pseudofilesystem.

nfsstat does want updating though. I'm not sure if Chuck and Olaf are
working on that as part of their iostat updates. Guys?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
