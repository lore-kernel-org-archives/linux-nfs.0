From: Greg Banks <gnb@melbourne.sgi.com>
Subject: [PATCH] SGI 904217 (1/2): allow enabling TCP without recompile
Date: Mon, 15 Dec 2003 19:14:46 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FDD6D76.84D65DD2@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVnsy-00028Q-SY
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 00:15:24 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=rj.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AVnsy-0006Qo-IR
	for nfs@lists.sourceforge.net; Mon, 15 Dec 2003 00:15:24 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
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

G'day,

These two patches Linux systems to be shipped with CONFIG_NFSD_TCP=y
but TCP support disabled at runtime until the sysadmin edits the
/etc/sysconfig/nfs file and restarts NFS.  The idea is that TCP
support is still disabled by default, but can be enabled with less
pain than currently is the case (we have customers who want to try
it).

The first patch is for the kernel and adds a new nfsctl which can
be used to enable or disable one or all transports known to the
kernel.  If CONFIG_NFSD_TCP=y this includes TCP, but TCP is still
disabled by default (it needs to be specifically enabled by new
code in /usr/sbin/rpc.nfsd, see the next patch).

Tested on an SGI ProPack 2.4 system.  All combinations of old/new
kernel/nfsd work as expected, and TCP is only enabled when the
appropriate option is given to nfsd.


===========================================================================
linux/linux/fs/nfsd/nfsctl.c
===========================================================================

--- /usr/tmp/TmpDir.8251-0/linux/linux/fs/nfsd/nfsctl.c_1.25	Mon Dec 15 17:25:27 2003
+++ linux/linux/fs/nfsd/nfsctl.c	Tue Dec  9 17:33:15 2003
@@ -34,6 +34,8 @@
 #include <linux/smp_lock.h>
 #include <linux/init.h>
 
+extern int	nfsd_set_transport(const char *name, int enabled);
+
 static int	nfsctl_svc(struct nfsctl_svc *data);
 static int	nfsctl_addclient(struct nfsctl_client *data);
 static int	nfsctl_delclient(struct nfsctl_client *data);
@@ -193,6 +195,13 @@
 	return err;
 }
 
+static inline int
+nfsctl_transport(struct nfsctl_transport *data)
+{
+	data->tr_name[sizeof(data->tr_name)-1] = '\0';
+	return nfsd_set_transport(data->tr_name, data->tr_enable);
+}
+
 #ifdef CONFIG_NFSD
 #define handle_sys_nfsservctl sys_nfsservctl
 #endif
@@ -209,6 +218,7 @@
 	/* NFSCTL_GETFH      */ { sizeof(struct nfsctl_fhparm), NFS_FHSIZE},
 	/* NFSCTL_GETFD      */ { sizeof(struct nfsctl_fdparm), NFS_FHSIZE},
 	/* NFSCTL_GETFS      */ { sizeof(struct nfsctl_fsparm), sizeof(struct knfsd_fh)},
+	/* NFSCTL_TRANSPORT  */ { sizeof(struct nfsctl_transport), 0 },
 };
 #define CMD_MAX (sizeof(sizes)/sizeof(sizes[0])-1)
 
@@ -282,6 +292,9 @@
 		err = nfsctl_getfs(&arg->ca_getfs, &res->cr_getfs);
 		respsize = res->cr_getfs.fh_size+ (int)&((struct knfsd_fh*)0)->fh_base;
 		break;
+	case NFSCTL_TRANSPORT:
+		err = nfsctl_transport(&arg->ca_transport);
+		break;
 	default:
 		err = -EINVAL;
 	}

===========================================================================
linux/linux/fs/nfsd/nfssvc.c
===========================================================================

--- /usr/tmp/TmpDir.8251-0/linux/linux/fs/nfsd/nfssvc.c_1.19	Mon Dec 15 17:25:27 2003
+++ linux/linux/fs/nfsd/nfssvc.c	Tue Dec  9 17:33:25 2003
@@ -68,6 +68,51 @@
  */
 #define	NFSD_MAXSERVS		8192
 
+
+struct nfsd_transport {
+	const char *name;
+	int enabled;
+};
+
+static struct nfsd_transport nfsd_transports[] = {
+{"udp", 	1},
+#if CONFIG_NFSD_TCP
+{"tcp", 	0},	/* TCP needs to be explicitly enabled from rpc.nfsd */
+#endif
+{NULL,		0}
+};
+
+static struct nfsd_transport *
+nfsd_find_transport(const char *name)
+{
+	struct nfsd_transport *ntp;
+	
+	for (ntp = nfsd_transports ; ntp->name != NULL ; ntp++) {
+		if (!strcmp(name, ntp->name))
+			return ntp;
+	}
+	return NULL;
+}
+
+int
+nfsd_set_transport(const char *name, int enabled)
+{
+	struct nfsd_transport *ntp;
+
+	if (name == NULL || *name == '\0') {
+		/* {en,dis}able all transports */
+		for (ntp = nfsd_transports ; ntp->name != NULL ; ntp++)
+			ntp->enabled = enabled;
+	} else if ((ntp = nfsd_find_transport(name)) != NULL) {
+		/* {en,dis}able a specific transport */
+		ntp->enabled = enabled;
+	} else {
+		return -EPROTONOSUPPORT;
+	}
+	return 0;
+}
+
+
 int
 nfsd_svc(unsigned short port, int nrservs)
 {
@@ -91,14 +136,19 @@
 		nfsd_serv = svc_create(&nfsd_program, NFSD_BUFSIZE, NFSSVC_XDRSIZE);
 		if (nfsd_serv == NULL)
 			goto out;
-		error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
-		if (error < 0)
-			goto failure;
-
+		if (nfsd_find_transport("udp")->enabled) {
+			dprintk("nfsd: creating UDP socket\n");
+			error = svc_makesock(nfsd_serv, IPPROTO_UDP, port);
+			if (error < 0)
+				goto failure;
+		}
 #if CONFIG_NFSD_TCP
-		error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
-		if (error < 0)
-			goto failure;
+    	    	if (nfsd_find_transport("tcp")->enabled) {
+			dprintk("nfsd: creating TCP socket\n");
+			error = svc_makesock(nfsd_serv, IPPROTO_TCP, port);
+			if (error < 0)
+				goto failure;
+		}
 #endif
 		do_gettimeofday(&nfssvc_boot);		/* record boot time */
 	} else

===========================================================================
linux/linux/include/linux/nfsd/syscall.h
===========================================================================

--- /usr/tmp/TmpDir.8251-0/linux/linux/include/linux/nfsd/syscall.h_1.7	Mon Dec 15
17:25:27 2003
+++ linux/linux/include/linux/nfsd/syscall.h	Tue Dec  9 17:29:21 2003
@@ -49,6 +49,7 @@
 #define NFSCTL_GETFH		6	/* get an fh by ino (used by mountd) */
 #define NFSCTL_GETFD		7	/* get an fh by path (used by mountd) */
 #define	NFSCTL_GETFS		8	/* get an fh by path with max FH len */
+#define NFSCTL_TRANSPORT	9	/* {en,dis}able transport(s) */
 
 /* SVC */
 struct nfsctl_svc {
@@ -110,6 +111,12 @@
 	int			gd_maxlen;
 };
 
+/* TRANSPORT - enable or disable one or all transports */
+struct nfsctl_transport {
+	int			tr_enable;	/* 1=enable 0=disable */
+	char			tr_name[32];	/* name or "" for all transports */
+};
+
 /*
  * This is the argument union.
  */
@@ -123,6 +130,7 @@
 		struct nfsctl_fhparm	u_getfh;
 		struct nfsctl_fdparm	u_getfd;
 		struct nfsctl_fsparm	u_getfs;
+		struct nfsctl_transport	u_transport;
 	} u;
 #define ca_svc		u.u_svc
 #define ca_client	u.u_client
@@ -132,6 +140,7 @@
 #define ca_getfd	u.u_getfd
 #define	ca_getfs	u.u_getfs
 #define ca_authd	u.u_authd
+#define ca_transport	u.u_transport
 };
 
 union nfsctl_res {




Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
