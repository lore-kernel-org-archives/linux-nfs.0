From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/2] mountd: remove bogus	mountlist_add/del	calls,
	track	only v2/3 mounts
Date: Wed, 25 Oct 2006 11:56:38 -0400
Message-ID: <1161791798.7078.74.camel@dantu.rdu.redhat.com>
References: <1161781622.7078.51.camel@dantu.rdu.redhat.com>
	<1161788942.20313.2.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gcl7f-0006vk-3K
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 08:56:55 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Gcl7Y-0004D6-UB
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 08:56:53 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1161788942.20313.2.camel@lade.trondhjem.org>
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

On Wed, 2006-10-25 at 08:09 -0700, Trond Myklebust wrote:
> An NFSv4 client will never talk to the mountd daemon at all. Not for
> mounting or for unmounting. It only talks to the NFS daemon, which will
> do an upcall to mountd in order to figure out what the export options
> are. That shouldn't result in an rmtab entry being created, though.
> 
> Cheers,
>   Trond

Right, sorry if I wasn't clear...

The problem there is in the upcall. It can result in cache_export_ent()
getting called which will call mountlist_add() unconditionally. The
patch corrects this by moving the mountlist_add() out of
cache_export_ent() and into get_rootfh().

-- Jeff



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
