From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 026 of 26] Subject: [PATCH] nfsd4_lock() returns bogus values to clients
Date: Fri, 13 Jan 2006 12:01:10 +1100
Message-ID: <1060113010110.23240@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJd-0002b9-8W
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:17 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJc-0006sB-SK
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:17 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:13 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:10 +1100
To: nfs@lists.sourceforge.net
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


From: Al Viro <viro@zeniv.linux.org.uk>
Date: 1135493243 -0500

missing nfserrno() in default case of a switch by return value of
posix_lock_file(); as the result we send negative host-endian to
clients that expect positive network-endian, preferably mentioned
in RFC...  BTW, that case is not impossible - posix_lock_file()
can return -ENOLCK and we do not handle that one explicitly.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    3 +++
 1 file changed, 3 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2006-01-13 11:51:10.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2006-01-13 11:51:11.000000000 +1100
@@ -2761,7 +2761,10 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 		goto conflicting_lock;
 	case (EDEADLK):
 		status = nfserr_deadlock;
+		dprintk("NFSD: nfsd4_lock: posix_lock_file() failed! status %d\n",status);
+		goto out;
 	default:        
+		status = nfserrno(status);
 		dprintk("NFSD: nfsd4_lock: posix_lock_file() failed! status %d\n",status);
 		goto out;
 	}


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
