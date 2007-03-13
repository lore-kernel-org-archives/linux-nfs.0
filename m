From: Wei Yongjun <yjwei@nanjing-fnst.com>
Subject: Re: [PATCH] nfs-utils umount command does not use correct
 TCP/UDP protocol
Date: Tue, 13 Mar 2007 11:12:58 +0800
Message-ID: <45F616BA.3030602@nanjing-fnst.com>
References: <1173098587.4825.9.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Cc: SteveD@redhat.com, Amit Gud <agud@redhat.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQxWK-0004Dr-3N
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 20:17:52 -0700
Received: from [221.6.14.228] (helo=proxy.fnst.com.cn)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HQxWL-0003h6-Hx
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 20:17:54 -0700
In-Reply-To: <1173098587.4825.9.camel@LINE>
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

Nobody replied yet, but I think this is really a BUG of umount.nfs command.

Following is my reasons:
(1). Let's to see, umount used LIFO to umount file systems, but in =

nfsumount.c's function get_mntproto(), it find the first mount entry's =

opts to do the umount operation, it seems to the FIFO mode.

(2). If I just used the file system path not the name of mounted file =

system in umount, =91if (strcmp(dirname, mntbuf.mnt_fsname)) =92 condition =

will be false, default IPPROTO_TCP value will be used.

(3). The latest kernel used "...,proto=3Dudp,..." format in file =

'/proc/mounts', not the old format '...,udp,...', so 'hasmntopt(&mntbuf, =

"udp")' condition will be always false under latest kernel, that is to =

say UDP protocol will be never used.

In my patch those problem has been fixed. This patch is for =

nfs-utils-1.0.12.

Signed-off-by: Wei Yongjun <yjwei@nanjing-fnst.com>

--- utils/mount/nfsumount.c.orig	2007-03-05 03:11:48.000000000 -0500
+++ utils/mount/nfsumount.c	2007-03-05 03:06:25.000000000 -0500
@@ -103,31 +103,35 @@ int nfs_call_umount(clnt_addr_t *mnt_ser
 	return 0;
 }
 =

+static int
+hasmntvalue(const char *list, const char *s) {
+	int n =3D strlen(s);
+	char *p, *rest =3D list;
+
+	while ((p =3D strstr(rest, s)) !=3D NULL) {
+		if ((p =3D=3D rest || p[-1] =3D=3D ',' || p[-1] =3D=3D '=3D')
+			&& (p[n] =3D=3D '\0' || p[n] =3D=3D ','))
+			return 1;
+
+		while (*rest && *rest++ !=3D ',');
+		if(rest =3D=3D NULL) break;
+	}
+	return 0;
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
 	u_int proto =3D IPPROTO_TCP; /* assume tcp */
 =

-	 mtab =3D setmntent ("/proc/mounts", "r");
-	 if (mtab =3D=3D NULL)
-	 	mtab =3D setmntent (_PATH_MOUNTED, "r");
-	if (mtab =3D=3D NULL)
-		return proto;
-
-	while(getmntent_r(mtab, &mntbuf, tmpbuf, sizeof (tmpbuf))) {
-		if (strcmp(mntbuf.mnt_type, "nfs"))
-			continue;
-		if (strcmp(dirname,  mntbuf.mnt_fsname))
-			continue;
-		if (hasmntopt(&mntbuf, "udp"))
-			proto =3D IPPROTO_UDP;
-		break;
-	}
-	endmntent (mtab);
+	mc =3D getmntdirbackward(dirname, NULL);
+	if (!mc)
+		mc =3D getmntdevbackward(dirname, NULL);
+
+	if(mc && hasmntvalue(mc->m.mnt_opts, "udp"))
+		proto =3D IPPROTO_UDP;
 =

 	return proto;
 }


> After I install nfs-utils-1.0.12, the least release, I found that umount
> command can not use the correct TCP/UDP protocol as which it been mount.
>
> You can test this used following commands:
> #mount -t nfs -o proto=3Dudp 127.0.0.1:/nfsroot /mnt
> #umount /mnt
> umount will use TCP protocol to do the umount process.
>   =


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
