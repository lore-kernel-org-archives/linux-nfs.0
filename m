From: "fj-shic" <shic@np.css.fujitsu.com>
Subject: [PATCH] nfs-utils - the problem about the "nfs bindresvport:
	Address already in use" in NFSv3
Date: Fri, 9 Feb 2007 11:53:42 +0900
Message-ID: <0aa301c74bf5$81eb9840$adb1220a@shic>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFLtc-0002Ud-5P
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 18:53:56 -0800
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFLtc-0006t1-Kk
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 18:53:58 -0800
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id
	l192rk2k012232
	for <nfs@lists.sourceforge.net> (envelope-from shic@np.css.fujitsu.com);
	Fri, 9 Feb 2007 11:53:47 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B349424005C
	for <nfs@lists.sourceforge.net>; Fri,  9 Feb 2007 11:53:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FF402DC06A
	for <nfs@lists.sourceforge.net>; Fri,  9 Feb 2007 11:53:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5 [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A415161C00B
	for <nfs@lists.sourceforge.net>; Fri,  9 Feb 2007 11:53:46 +0900 (JST)
Received: from ml2.s.css.fujitsu.com (ml2.s.css.fujitsu.com [10.23.4.192])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EBDDF161C00C
	for <nfs@lists.sourceforge.net>; Fri,  9 Feb 2007 11:53:45 +0900 (JST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi, All



When I did some NFSv3 mount operations, I found the problem abut the  "nfs 
binodresvport: Address already in use" in NFSv3.

I mounted NFSv3 in TCP protocol, after lots of continuous mount operations, 
the error "nfs bindresvport: Address already in use" always happened, as the 
count of the mounted NFS reaches about 500, even I added the "insecure" 
option to the exports entry of the NFS server.



My system is RHEL5 and the mount operation for NFSv3 is implemented in 
nfs-utils-1.0.9-10.

 I have investigated the problem, and found the cause was the limitation of 
the bindresvport in nfsmount.



 In nfsmount, nfsmount() will create a socket for NFS, and just bind the 
socket to a reserve port. For the bindresvport() just can use the port 
number in the range 512-1023, after the lots of continuous mount operations, 
the reserved ports will all be in TIME_WAIT during the mount storm but can 
not be released in time, then next mount operation will usually fails by 
bindresvport().



In NFS server exports configuration, the 'insecure' option allows clients 
with NFS implementations that don't use a reserved port for NFS, so I think 
the port range can be expended so the entire port space can be tried, for a 
reserved port is not always needed when the 'insecure' option is allowed.


 For the problem in the nfsmount, I have made the patch below for the 
limitation of the bindresvport, and make the socket can be bound to a 
non-reserve port when the bindresvport fails.
 I have tested it as the "insecure" is set, after the patch is applied, the 
limitation with "nfs binodresvport:" can be avoided.



Any idea for it is welcome!

Thanks

Regards

ShiChao
 signed-off-by:ShiChao <shic@nanjing-fnst.com>
--- nfs-utils-1.0.9-orig/utils/mount/nfsmount.c 2007-01-31 
17:12:26.000000000 -0500
+++ nfs-utils-1.0.9/utils/mount/nfsmount.c 2007-02-01 
05:13:48.000000000 -0500
@@ -851,6 +851,7 @@
  time_t t;
  time_t prevt;
  time_t timeout;
+  struct sockaddr_in laddr;

  /* The version to try is either specified or 0
     In case it is 0 we tell the caller what we tried */
@@ -1139,10 +1140,18 @@
   perror(_("nfs socket"));
   goto fail;
  }
+
  if (bindresvport(fsock, 0) < 0) {
-  perror(_("nfs bindresvport"));
-  goto fail;
- }
+  perror(_("nfs bindresvport fail, try a non-reserver port"));
+  laddr.sin_family = AF_INET;
+  laddr.sin_port = 0;
+  laddr.sin_addr.s_addr = htonl(INADDR_ANY);
+  if ( bind(fsock, (struct sockaddr *)&laddr, sizeof(laddr)) < 0 ){
+   perror(_("nfs bind"));
+   goto fail;
+  }
+  }
+
 #ifdef NFS_MOUNT_DEBUG
  printf(_("using port %d for nfs deamon\n"), nfs_pmap->pm_port);
 #endif




-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
