From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 014 of 26] nfsd4: recovery lookup dir check
Date: Fri, 13 Jan 2006 12:00:59 +1100
Message-ID: <1060113010059.23096@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJb-0002b0-Ps
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:15 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJW-00050c-KN
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:15 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:03 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:00 +1100
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


Make sure we get a directory when we look up the recovery directory.

Thanks to Christoph Hellwig for the bug report.

Based on feedback from Christoph and others, we may remove the need for
this lookup and just pass in a file descriptor from userspace instead,
and/or completely move the directory handling to userspace.  For now we're
just fixing the obvious bugs.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4recover.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs4recover.c~current~ ./fs/nfsd/nfs4recover.c
--- ./fs/nfsd/nfs4recover.c~current~	2006-01-13 11:51:07.000000000 +1100
+++ ./fs/nfsd/nfs4recover.c	2006-01-13 11:51:08.000000000 +1100
@@ -399,9 +399,10 @@ nfsd4_init_recdir(char *rec_dirname)
 
 	nfs4_save_user(&uid, &gid);
 
-	status = path_lookup(rec_dirname, LOOKUP_FOLLOW, &rec_dir);
-	if (status == -ENOENT)
-		printk("NFSD: recovery directory %s doesn't exist\n",
+	status = path_lookup(rec_dirname, LOOKUP_FOLLOW | LOOKUP_DIRECTORY,
+			&rec_dir);
+	if (status)
+		printk("NFSD: unable to find recovery directory %s\n",
 				rec_dirname);
 
 	if (!status)


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
