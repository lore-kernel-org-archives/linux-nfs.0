From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 015 of 26] nfsd4: handle replays of failed open reclaims
Date: Fri, 13 Jan 2006 12:01:00 +1100
Message-ID: <1060113010100.23108@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJV-0002Zp-8h
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:09 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJT-0004xA-DC
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:09 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.18] == smtp-dist-03.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:03 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Fri, 13 Jan 2006 12:01:01 +1100
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


We need to make sure open reclaims are marked confirmed immediately so that
we can handle replays even if they fail (e.g. with a seqid-incrementing error).
(See 8.1.8.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |    2 ++
 1 file changed, 2 insertions(+)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2006-01-13 11:51:06.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-01-13 11:51:08.000000000 +1100
@@ -210,6 +210,7 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 				goto out;
 			break;
 		case NFS4_OPEN_CLAIM_PREVIOUS:
+			open->op_stateowner->so_confirmed = 1;
 			/*
 			 * The CURRENT_FH is already set to the file being
 			 * opened.  (1) set open->op_cinfo, (2) set
@@ -221,6 +222,7 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 				goto out;
 			break;
              	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
+			open->op_stateowner->so_confirmed = 1;
 			printk("NFSD: unsupported OPEN claim type %d\n",
 				open->op_claim_type);
 			status = nfserr_notsupp;


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
