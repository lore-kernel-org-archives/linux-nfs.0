From: Greg Banks <gnb@sgi.com>
Subject: ETIMEDOUT in nfsd?
Date: Tue, 3 Aug 2004 18:15:03 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040803081503.GM5581@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Brueb-0004wb-TN
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 01:28:13 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Brueb-00071N-HQ
	for nfs@lists.sourceforge.net; Tue, 03 Aug 2004 01:28:13 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

G'day,

I'm looking at porting to 2.6 the SGI ProPack code for supporting
Hierarchical Storage Managers in nfsd.  Basically, this comprises 
telling the filesystem to do stuff non-blocking at various times
(read, write and setattr) and converting the resulting -EAGAIN
when the HSM has to go out to tape into NFSERR_JUKEBOX to the
client.

So I was somewhat surprised to see that in 2.6, the mapping from
Linux errno to NFS error in fs/nfsd/nfsproc.c:nfserrno() maps
-EAGAIN to nfserr_dropit, causing nfsd_dispatch to just drop the
call and not reply.  Furthermore I need to return the network
error -ETIMEDOUT to get NFSERR_JUKEBOX.  I don't get it...can
someone explain both of these?

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
