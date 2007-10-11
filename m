From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 06/12] text-based mount.nfs:
Date: Thu, 11 Oct 2007 13:29:59 +1000
Message-ID: <18189.39095.274290.825015@notabene.brown>
References: <20071008155407.15051.60775.stgit@manray.1015granger.net>
	<18186.56139.301135.961540@notabene.brown>
	<5847045D-72E9-4322-AB08-F8952C26AA44@oracle.com>
	<18189.32027.462332.151295@notabene.brown>
	<470D8F45.8020202@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfokQ-0004Ms-JS
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 20:30:06 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfokT-0000is-4K
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 20:30:11 -0700
In-Reply-To: message from Chuck Lever on Wednesday October 10
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

On Wednesday October 10, chuck.lever@oracle.com wrote:
> > 
> > I've broken the link, so the unmount now succeeds.  It would be good
> > to get it to send the right request to the server though, either by
> > recording the protocol in mtab, or using probe_mntport or similar.
> 
> Yeah, that's odd.  It is supposed to be probing the server's mountd in 
> nfs_call_umount.  The problem may be that it's only trying a single 
> mount RPC (for vers=3), and not doing any kind of version fallback.

Thanks for the pointers.  I've got it working, though the patch
(below) is a big ugly at this stage.

Two key fixes:
  1/ Don't give up probing if we get RPC_PROGVERSMISMATCH.
  2/ Don't set pm_vers if it isn't set in mtab.  Leave it at zero so
     the probe routines get a chance to do the right thing.

   An awkwardness here was we were overloading the meaning of 
        pm_vers == 0
   In some contexts it means "Has not been explicitly set, probe".
   In other contexts it means "Mountd is not used (due to NFSv4)".

   I introduced '63356' for the second meaning, but would rather a
   cleaner approach.

   Maybe we don't need the second meaning, as the 2/3 versus 4
   distinction is present in mnt_type so we never call do_nfs_umount
   for a v4 mount.  Is that true?

NeilBrown

  

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 49d3c6b..c37d0f3 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -85,7 +85,7 @@ unsigned long nfsvers_to_mnt(const unsigned long vers)
 {
 	if (vers <= 3)
 		return nfs_to_mnt[vers];
-	return 0;
+	return 65536; /* invalid */
 }
 
 /*
@@ -408,7 +408,8 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
 					goto out_bad;
 			}
 		}
-		if (rpc_createerr.cf_stat != RPC_PROGNOTREGISTERED)
+		if (rpc_createerr.cf_stat != RPC_PROGNOTREGISTERED &&
+		    rpc_createerr.cf_stat != RPC_PROGVERSMISMATCH)
 			goto out_bad;
 
 		if (!prot) {
@@ -589,6 +590,7 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 	case 3:
 	case 2:
 	case 1:
+	case 0:
 		if (!probe_mntport(mnt_server))
 			return 0;
 		clnt = mnt_openclnt(mnt_server, &msock);
@@ -602,7 +604,7 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 		if (res == RPC_SUCCESS)
 			return 1;
 		break;
-	default:
+	default: /* invalid - must be NFSv4 which doesn't use MOUNT */
 		res = RPC_SUCCESS;
 		break;
 	}
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 9e9cd16..051592b 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -190,7 +190,7 @@ static int do_nfs_umount(const char *spec, char *opts)
 	}
 
 	pmap->pm_prog = MOUNTPROG;
-	pmap->pm_vers = MOUNTVERS_NFSV3;
+	pmap->pm_vers = 0; /* unknown */
 	if (opts && (p = strstr(opts, "mountprog=")) && isdigit(*(p+10)))
 		pmap->pm_prog = atoi(p+10);
 	if (opts && (p = strstr(opts, "mountport=")) && isdigit(*(p+10)))

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
