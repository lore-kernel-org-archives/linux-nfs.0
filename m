From: Jason Holmes <jholmes@psu.edu>
Subject: Re: NFS Server problem (kernel > 2.6.5 ?)
Date: Wed, 27 Oct 2004 14:01:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <417FE293.9050204@psu.edu>
References: <001801c4bb3d$5d670bd0$1203a8c0@utvikling> <417E8DFA.5090204@psu.edu> <001501c4bc44$051867a0$1203a8c0@utvikling> <20041027165017.GE4292@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060504080201060702020904"
Cc: mrg <mrg@normailer.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CMs6y-0002ki-Nw
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 11:01:28 -0700
Received: from vpn-19-5.aset.psu.edu ([146.186.19.5] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CMs6w-0007Sp-KM
	for nfs@lists.sourceforge.net; Wed, 27 Oct 2004 11:01:28 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041027165017.GE4292@fieldses.org>
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

This is a multi-part message in MIME format.
--------------060504080201060702020904
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Wed, Oct 27, 2004 at 06:43:00PM +0200, mrg wrote:
> 
>>Thanks, it worked!
>>
>>I uninstalled the nfs-utils-1.0.6-22 (from FC2), then installed
>>nfs-utils-1.0.6 from kernel.org. Et voila!
> 
> 
> If you download the FC2 srpm you can see the list of patches that
> distinguishes their version from stock nfs-utils-1.0.6.  It might be
> useful to figure out exactly which of those patches it is that causes
> the problem.

For the Enterprise build, it's the "nfs-utils-1.0.6-mountd.patch" patch. 
  I've attached a copy.

Thanks,

--
Jason Holmes


--------------060504080201060702020904
Content-Type: text/plain;
 name="nfs-utils-1.0.6-mountd.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-mountd.patch"

#
# Make sure check_new_cache() is looking in the right place
#
--- src/support/nfs/cacheio.c.org	2003-08-04 00:12:16.000000000 -0400
+++ src/support/nfs/cacheio.c	2004-03-22 18:12:55.163534208 -0500
@@ -223,12 +223,23 @@ int readline(int fd, char **buf, int *le
  * This succeeds iff the "nfsd" filesystem is mounted on
  * /proc/fs/nfs
  */
+static char *cachelist[] = {
+	{ "auth.unix.ip" }, { "nfsd.export" }, { "nfsd.fh" }, 
+	{ NULL, NULL }
+};
 int
 check_new_cache(void)
 {
 	struct stat stb;
-	return	(stat("/proc/fs/nfs/filehandle", &stb) == 0) ||
-		(stat("/proc/fs/nfsd/filehandle", &stb) == 0);
+	char path[64];
+	int i;
+
+	for (i=0; cachelist[i]; i++ ){
+		sprintf(path, "/proc/net/rpc/%s/channel", cachelist[i]);
+		if (stat(path, &stb) < 0)
+			return 0;
+	}
+	return 1;
 }	


#
# Eliminate 3 syslog message that are logged for
# successful events.
#
--- src/utils/mountd/mountd.c.org	2003-09-12 18:14:16.000000000 -0400
+++ src/utils/mountd/mountd.c	2004-06-16 09:31:06.000000000 -0400
@@ -90,10 +90,11 @@ mount_dump_1_svc(struct svc_req *rqstp, 
 {
 	struct sockaddr_in *addr =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-	xlog(L_NOTICE, "dump request from %s",
-		inet_ntoa(addr->sin_addr));
 
-	*res = mountlist_list();
+	if ((*res = mountlist_list()) == NULL)
+		xlog(L_WARNING, "dump request from %s failed.",
+			inet_ntoa(addr->sin_addr));
+
 	return 1;
 }
 
@@ -143,9 +144,11 @@ mount_export_1_svc(struct svc_req *rqstp
 {
 	struct sockaddr_in *addr =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-	xlog(L_NOTICE, "export request from %s",
-		inet_ntoa(addr->sin_addr));
-	*resp = get_exportlist();
+
+	if ((*resp = get_exportlist()) == NULL)
+		xlog(L_WARNING, "export request from %s failed.",
+			inet_ntoa(addr->sin_addr));
+		
 	return 1;
 }
 
@@ -154,9 +157,10 @@ mount_exportall_1_svc(struct svc_req *rq
 {
 	struct sockaddr_in *addr =
 		(struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
-	xlog(L_NOTICE, "exportall request from %s",
-		inet_ntoa(addr->sin_addr));
-	*resp = get_exportlist();
+
+	if ((*resp = get_exportlist()) == NULL)
+		xlog(L_WARNING, "exportall request from %s failed.",
+			inet_ntoa(addr->sin_addr));
 	return 1;
 }
 

--------------060504080201060702020904--


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
