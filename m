From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: NFS and tinygrams
Date: Thu, 21 Oct 2004 10:05:26 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098378325.3601.153.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKgNY-0007O8-MC
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 10:05:32 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CKgNV-0006SE-0x
	for nfs@lists.sourceforge.net; Thu, 21 Oct 2004 10:05:32 -0700
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
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


We have a series of test transfers going, where we are shuttling data
from GFS->NFS V3 over UDP->NFS V3 over TCP->Lustre.

On the NFS V3 over TCP link, we're seeing a lot of tinygrams, despite
having 8K NFS block sizes turned on, and jumbo packets enabled (9000
byte MTU).

The GFS machine runs Redhat 9, the first NFS server also runs Redhat 9. 
The machine copying from NFS to NFS is running AIX 5.1.  The machine
copying NFS to Lustre is running RHEL 3.

I didn't check on the packet sizes of the other legs of the transfer.

I've verified that we do have jumbo packets being used some of the time,
on that AIX 5.1 -> RHEL 3 hop.  However, we're still getting a pretty
large percentage of tinygrams.

Is there any way of cutting down on the tinygrams, to more effectively
utilize our large MTU?  Is there perhaps any sort of "intent based"
packetizing in standard implementations of NFS on Redhat 9, AIX 5.1,
and/or RHEL 3?

(Yes, we could short circuit the AIX 5.1 part of the transfer, and that
Would make things faster, but it Wouldn't test what we need to test!)

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
