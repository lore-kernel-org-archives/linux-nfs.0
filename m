From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: [PATCH] nfs-utils umount command does not use correct
	TCP/UDP	protocol
Date: Mon, 05 Mar 2007 07:43:06 -0500
Message-ID: <1173098587.4825.9.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOAsX-0002EY-PS
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 02:57:18 -0800
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HOAsX-0005Sg-9f
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 02:57:20 -0800
Received: from 192.168.100.160 ([192.168.1.58])
	by proxy.fnst.com.cn (8.12.11/8.12.11) with ESMTP id l25Av2AX001257
	for <nfs@lists.sourceforge.net>; Mon, 5 Mar 2007 18:57:03 +0800
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

After I install nfs-utils-1.0.12, the least release, I found that umount
command can not use the correct TCP/UDP protocol as which it been mount.

You can test this used following commands:
#mount -t nfs -o proto=udp 127.0.0.1:/nfsroot /mnt
#umount /mnt
umount will use TCP protocol to do the umount process.

Following is my patch to fix this BUG.

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- utils/mount/nfsumount.c.orig	2007-03-05 03:11:48.000000000 -0500
+++ utils/mount/nfsumount.c	2007-03-05 03:06:25.000000000 -0500
@@ -103,31 +103,35 @@ int nfs_call_umount(clnt_addr_t *mnt_ser
 	return 0;
 }
 
+static int
+contains(const char *list, const char *s) {
+	int n = strlen(s);
+	char *p, *rest = list;
+
+	while ((p = strstr(rest, s)) != NULL) {
+		if ((p == rest || p[-1] == ',' || p[-1] == '=')
+			&& (p[n] == '\0' || p[n] == ','))
+			return 1;
+
+                while (*rest && *rest++ != ',');
+		if(rest == NULL) break;
+        }
+        return 0;
+}
+
 u_int get_mntproto(const char *);
 u_int
 get_mntproto(const char *dirname)
 {
-	FILE *mtab;
-	struct mntent mntbuf;
-	char tmpbuf[BUFSIZ];
+	struct mntentchn *mc;
 	u_int proto = IPPROTO_TCP; /* assume tcp */
 
-	 mtab = setmntent ("/proc/mounts", "r");
-	 if (mtab == NULL)
-	 	mtab = setmntent (_PATH_MOUNTED, "r");
-	if (mtab == NULL)
-		return proto;
-
-	while(getmntent_r(mtab, &mntbuf, tmpbuf, sizeof (tmpbuf))) {
-		if (strcmp(mntbuf.mnt_type, "nfs"))
-			continue;
-		if (strcmp(dirname,  mntbuf.mnt_fsname))
-			continue;
-		if (hasmntopt(&mntbuf, "udp"))
-			proto = IPPROTO_UDP;
-		break;
-	}
-	endmntent (mtab);
+	mc = getmntdirbackward(dirname, NULL);
+	if (!mc)
+		mc = getmntdevbackward(dirname, NULL);
+
+	if(mc && contains(mc->m.mnt_opts, "udp"))
+		proto = IPPROTO_UDP;
 
 	return proto;
 }



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
