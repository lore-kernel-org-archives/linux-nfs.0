From: Neil Horman <nhorman@redhat.com>
Subject: Re: Strange problem with ACL over NFS
Date: Fri, 1 Jul 2005 09:43:07 -0400
Message-ID: <20050701134307.GC13619@hmsendeavour.rdu.redhat.com>
References: <42C3DBDC.5050803@bio.ifi.lmu.de> <1120157929.8922.14.camel@lade.trondhjem.org> <42C4DA08.8070202@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	NFS NFS <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DoLny-0001MP-Fu
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 06:43:42 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DoLnx-0002Hh-4a
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 06:43:42 -0700
To: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
In-Reply-To: <42C4DA08.8070202@bio.ifi.lmu.de>
Sender: nfs-admin@lists.sourceforge.net
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

On Fri, Jul 01, 2005 at 07:52:08AM +0200, Frank Steiner wrote:
> Trond Myklebust wrote
> 
> >to den 30.06.2005 Klokka 13:47 (+0200) skreiv Frank Steiner:
> >
> >>Any ideas what could go wrong here?
> >
> >There is no client side NFS ACL support for NFSv2. Have you tried a
> >'cat /proc/mounts' to check that the partition is indeed mounted as
> >NFSv3 when reading the ACLs fails?
> 
> Yes, it definitely is mounted with v3.
> 
> Here's sth. new I found out this morning: It looks like the _first_
> NFS mount from the server does not get ACLs. I.e., when I switch the
> order of the entries so that /rpm is mounted first, /home second, then
> the ACLs are visible on /home but not on rpm.
> I added a second NFS server with one export and activated ACLs there,
> and it's still the same: Whichever of the three mounts comes first
> does not have ACLs until it is unmounted and remounted. So if the
> new NFS mount entry comes first on the client, both /rpm and /home
> will have ACLs.
> 
> So this looks more like a client bug to me, because it is not always
> the first mount from the same server that does not have ACL, but the
> first overall NFS mount. Like the client was not able to initialize
> ACLs for NFS before the first mount is done...
> 
> I will check a recent kernel on the client side.
> 
> cu,
> Frank
> 
Just out of curiosity what kind of file system are the NFS servers export to
NFS?  Is it a shared cluster fs, like vxfs, or ocfs, or the like, or is it just
plain old ext3?
Neil

> -- 
> Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
> Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
> LMU, Amalienstr. 17           Phone: +49 89 2180-4049
> 80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
> * Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *
> 
> 
> -------------------------------------------------------
> SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
> from IBM. Find simple to follow Roadmaps, straightforward articles,
> informative Webcasts and more! Get everything you need to get up to
> speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
