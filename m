From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Wed, 27 Oct 2004 10:40:13 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098837612.21421.1344.camel@hole.melbourne.sgi.com>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
	 <1098413781.21421.37.camel@hole.melbourne.sgi.com>
	 <20041022024349.GA30004@fieldses.org>
	 <1098696830.21421.163.camel@hole.melbourne.sgi.com>
	 <1098715298.10720.38.camel@lade.trondhjem.org>
	 <1098775926.21421.371.camel@hole.melbourne.sgi.com>
	 <1098809731.10567.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Dr. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMbYI-0002W2-VZ
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 17:20:34 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CMbYI-0003Z4-D9
	for nfs@lists.sourceforge.net; Tue, 26 Oct 2004 17:20:34 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1098809731.10567.5.camel@lade.trondhjem.org>
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

On Wed, 2004-10-27 at 02:55, Trond Myklebust wrote:
> ty den 26.10.2004 Klokka 17:32 (+1000) skreiv Greg Banks:
> 
> > BTW, the following hunk is in your 2.6.10-rc1 NFS_ALL.dif but missing
> > from the corresponding exploded patchset.
> > 
> 
> Err. No... It should appears as the very last hunk in
> linux-2.6.9-17-fix_nfs_nolock.dif

Oh, I see: linux-2.6.9-17-fix_nfs_nolock.dif isn't linked to
from the initial section of the page, which goes from -16 to -18.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
