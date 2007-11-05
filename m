From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH nfs-utils 2/3] Correctly probe mount v2
Date: Mon, 05 Nov 2007 05:58:59 -0500
Message-ID: <472EF773.5020200@RedHat.com>
References: <1193894817-20622-1-git-send-email-neilb@suse.de>
	<1193894817-20622-2-git-send-email-neilb@suse.de>
	<1193894817-20622-3-git-send-email-neilb@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IozjM-0001O7-Pn
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 03:02:56 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IozjR-0002s2-TX
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 03:03:02 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lA5B2r9a008340
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 06:02:53 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com
	[172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lA5B2qWU000794
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 06:02:52 -0500
Received: from [10.13.248.25] (vpn-248-25.boston.redhat.com [10.13.248.25])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id
	lA5B2pb1023073
	for <nfs@lists.sourceforge.net>; Mon, 5 Nov 2007 06:02:51 -0500
In-Reply-To: <1193894817-20622-3-git-send-email-neilb@suse.de>
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



Neil Brown wrote:
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index 2b09457..38d0135 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -494,7 +494,7 @@ int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
>  	for (; *probe_vers; probe_vers++) {
>  		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
>  		if ((res = probe_nfsport(nfs_server) != 0)) {
> -			mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
> +			mnt_pmap->pm_vers = *probe_vers;
>  			if ((res = probe_mntport(mnt_server)) != 0)
>  				return 1;
>  			memcpy(mnt_pmap, &save_mnt, sizeof(*mnt_pmap));

This patch does indeed fix mounts in the case where servers only support
version 2 of the mount protocol. Meaning "mount server:/export /mnt/v2"
now work when mountd only registers version 2 of the mnt protocol.

But I happen to also notice that when setting the nfsvers
    "mount -o vers=2 server:/export /mnt/v2"

the mount fails, because the mount command assumes version 1 (of the mnt
protocol) should be used and never tries any other versions. A similar
assumption is made on the umount side as well.

So I guess the question is, what correlation (if any) is there between
the mount version and nfs version that is used? Do nfsvers=2 mounts
have to use version 1 of the mnt protocol? What is the problem if
v3 mounts use version 2 of the mnt protocol?

My answers would be None, No and None to those questions, but maybe
I'm missing something...

Below is an RFC patch that removes these assumption:

  diff --git a/utils/mount/network.c b/utils/mount/network.c
index 38d0135..c929986 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -481,8 +481,12 @@ int probe_bothports(clnt_addr_t *mnt_server, 
clnt_addr_t *nfs_server)

  	if (mnt_pmap->pm_vers && !nfs_pmap->pm_vers)
  		nfs_pmap->pm_vers = mntvers_to_nfs(mnt_pmap->pm_vers);
-	else if (nfs_pmap->pm_vers && !mnt_pmap->pm_vers)
-		mnt_pmap->pm_vers = nfsvers_to_mnt(nfs_pmap->pm_vers);
+	else if (nfs_pmap->pm_vers && !mnt_pmap->pm_vers) {
+		/* Does it matter which mount version is used
+		 * when the nfs version is set ?
+		 */
+		mnt_pmap->pm_vers = 0;
+	}
  	if (nfs_pmap->pm_vers)
  		goto version_fixed;

diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 285273b..4209514 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -195,12 +195,6 @@ static int do_nfs_umount23(const char *spec, char 
*opts)
  		pmap->pm_prog = atoi(p+10);
  	if (opts && (p = strstr(opts, "mountport=")) && isdigit(*(p+10)))
  		pmap->pm_port = atoi(p+10);
-	if (opts && hasmntopt(&mnt, "v2"))
-		pmap->pm_vers = nfsvers_to_mnt(2);
-	if (opts && hasmntopt(&mnt, "v3"))
-		pmap->pm_vers = nfsvers_to_mnt(3);
-	if (opts && (p = strstr(opts, "vers=")) && isdigit(*(p+5)))
-		pmap->pm_vers = nfsvers_to_mnt(atoi(p+5));
  	if (opts && (p = strstr(opts, "mountvers=")) && isdigit(*(p+10)))
  		pmap->pm_vers = atoi(p+10);
  	if (opts && (hasmntopt(&mnt, "udp") || hasmntopt(&mnt, "proto=udp")))


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
