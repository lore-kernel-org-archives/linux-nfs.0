From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 013 of 26] nfsd4: fix open of recovery directory
Date: Fri, 13 Jan 2006 12:00:59 +1100
Message-ID: <1060113010059.23084@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJW-0002Zu-1E
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:10 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJU-0004yY-Dp
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:10 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.18] == smtp-dist-03.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:03 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:00:59 +1100
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


We should be opening this directory RDONLY, not RDWR.

Thanks to Christoph Hellwig for the bug report.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4recover.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2006-01-13 11:50:54.000000000 +1100
+++ ./fs/nfsd/nfs4recover.c	2006-01-13 11:51:07.000000000 +1100
@@ -222,8 +222,7 @@ nfsd4_list_rec_dir(struct dentry *dir, r
 
 	nfs4_save_user(&uid, &gid);
 
-	filp = dentry_open(dget(dir), mntget(rec_dir.mnt),
-			O_RDWR);
+	filp = dentry_open(dget(dir), mntget(rec_dir.mnt), O_RDONLY);
 	status = PTR_ERR(filp);
 	if (IS_ERR(filp))
 		goto out;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
