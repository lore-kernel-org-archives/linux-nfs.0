From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: NFS write errors
Date: Wed, 13 Oct 2004 09:49:37 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1097686177.8133.2915.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHmKs-0001zt-4z
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 09:50:46 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CHmJp-0007aZ-TB
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 09:50:46 -0700
To: nfs@lists.sourceforge.net
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


We are occasionally getting NFS write errors when writing terrabytes of
data from an AIX 5.1 system to an RHEL 3 system, using the version of
in-kernel NFS that comes with RHEL 3.  We're using 8k rsize, 8k wsize,
nfs v3, and tcp presently, but this isn't written in stone.

Has anyone else seen this?

Has anyone found a workaround?

Does anyone have any suggestions, speculative or otherwise?

Thanks!

-- 
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
