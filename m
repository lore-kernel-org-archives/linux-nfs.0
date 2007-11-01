From: Neil Brown <neilb@suse.de>
Subject: [PATCH nfs-utils 2/3] Correctly probe mount v2
Date: Thu,  1 Nov 2007 16:26:56 +1100
Message-ID: <1193894817-20622-3-git-send-email-neilb@suse.de>
References: <1193894817-20622-1-git-send-email-neilb@suse.de>
	<1193894817-20622-2-git-send-email-neilb@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InSaG-0004HL-5i
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 22:27:12 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InSaK-00045o-B7
	for nfs@lists.sourceforge.net; Wed, 31 Oct 2007 22:27:17 -0700
In-Reply-To: <1193894817-20622-2-git-send-email-neilb@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

When following a list of mount versions to probe -
e.g. probe_mnt1_first or probe_mnt3_first - probe_both will first
probe the appropriate NFS version and then, if that succeeds, probe
the actual mount version.  However instead of probing the target mount
version, it probes the "most appropriate" mount version for the given NFS version.
This results in it probing:
  NFSv2, MOUNTv1
twice rather than
  NFSv2, MOUNTv1
  NFSv2, MOUNTv2

as would be more correct.

This patch removes the "choose most correct" step and just use the
current mouint version for the probe_vers array.

Signed-off-by: Neil Brown <neilb@suse.de>
---
 utils/mount/network.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 2b09457..38d0135 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -494,7 +494,7 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 	for (; *probe_vers; probe_vers++) {
 		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
 		if ((res = probe_nfsport(nfs_server) != 0)) {
-			mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
+			mnt_pmap->pm_vers = *probe_vers;
 			if ((res = probe_mntport(mnt_server)) != 0)
 				return 1;
 			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));
-- 
1.5.3.4


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
