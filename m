From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfsstat zeroing RPC statistics 1/2
Date: Tue, 30 Dec 2003 13:32:02 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FF1C4A2.1060003@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050508010207040000070507"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AbOf4-0000yK-Au
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 10:32:10 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AbOf3-0005b6-TJ
	for nfs@lists.sourceforge.net; Tue, 30 Dec 2003 10:32:09 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.11.6/8.11.6) with ESMTP id hBUIW3A02248
	for <nfs@lists.sourceforge.net>; Tue, 30 Dec 2003 13:32:03 -0500
Received: from RedHat.com (vpn50-36.rdu.redhat.com [172.16.50.36])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hBUIW3E14989
	for <nfs@lists.sourceforge.net>; Tue, 30 Dec 2003 13:32:03 -0500
To: nfs@lists.sourceforge.net
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
--------------050508010207040000070507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

The attached patch adds the -z flag to the nfsstat command that
can be used to zero out both the client and server RPC statistics.
Basically... the man pages says it all...

       -z     Zeros out all or some of the statistics. Typical uses 
would be:
                 nfsstat -z  - zeros all statistics
                 nfsstat -zc - zeros only client statistics
                 nfsstat -zs - zeros only server statistics
                 nfsstat -zr - zeros only RPC statistics
                 nfsstat -zn - zeros only NFS call statistics

To complete the support kernel patch is required (which will
be in the second part of this patch).

The user and kernel interface is pretty simple, I simply
sent down the bits in the 'opt_prt' variable,  which in turn,
decides  which part of the rpc_stat or svc_stat structure that
is zeroed.

The kernel patch changes the permission modes on
the /proc/net/rpc/nfs[d] files from 0444 (-r-r-r) to
0644 (-rw-r-r). This is how the nfsstat patch  detects
whether zeroing is supported and this also means that
only root can zero out the stats.

Finally, protocol versions that have zero activity
are no longer displayed. This makes the output much
less noisy and a lot more concise.... Using the -a flag
will turn this off...

SteveD.



--------------050508010207040000070507
Content-Type: text/plain;
 name="linux-2.6.0-nfs-zerostats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.0-nfs-zerostats.patch"

--- linux-2.6.0/net/sunrpc/stats.c.orig	2003-12-17 22:00:00.000000000 -0500
+++ linux-2.6.0/net/sunrpc/stats.c	2003-12-28 12:33:47.876847000 -0500
@@ -20,6 +20,7 @@
 #include <linux/proc_fs.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svcsock.h>
+#include <asm/uaccess.h>
 
 #define RPCDBG_FACILITY	RPCDBG_MISC
 
@@ -120,17 +121,130 @@ svc_proc_read(char *buffer, char **start
 	return len;
 }
 
+#define PRNT_CALLS  0x0001
+#define PRNT_RPC    0x0002
+#define PRNT_NET    0x0004
+#define PRNT_FH     0x0008
+#define PRNT_RC     0x0010
+#define PRNT_ALL    0xffff
+
+#define HEX_DIGITS 8
+static inline unsigned int
+rpc_proc_getval(char *val, int vallen, 
+	const char *buf, unsigned long cnt)
+{
+	unsigned int new_value = 0;
+	int i;
+
+	if (!cnt)
+		return -EINVAL;
+	if (cnt > vallen)
+		cnt = vallen;
+	if (copy_from_user(val, buf, cnt))
+		return -EFAULT;
+
+	new_value = 0;
+	for (i = 0; i < cnt; i++) {
+		unsigned int c = val[i];
+
+		switch (c) {
+			case '0' ... '9': c -= '0'; break;
+			case 'a' ... 'f': c -= 'a'-10; break;
+			case 'A' ... 'F': c -= 'A'-10; break;
+		default:
+			goto out;
+		}
+		new_value = (new_value << 4) | c;
+	}
+out:
+	return new_value;
+}
+static int
+svc_proc_write(struct file *file, const char *buffer, 
+	unsigned long count, void *data)
+{
+	struct svc_stat *statp	= (struct svc_stat *) data;
+	struct svc_program *prog = statp->program;
+	struct svc_procedure *proc;
+	struct svc_version *vers;
+	char hexnum [HEX_DIGITS];
+	unsigned int opt_prt;
+	int i, j;
+
+	opt_prt = rpc_proc_getval(hexnum, HEX_DIGITS, buffer, count);
+	if (opt_prt < 0) 
+		return opt_prt;
+
+	if (opt_prt & PRNT_NET) { 
+		statp->netcnt = 0,
+		statp->netudpcnt = 0,
+		statp->nettcpcnt = 0,
+		statp->nettcpconn = 0;
+	}
+	if (opt_prt & PRNT_CALLS) {
+		for (i = 0; i < prog->pg_nvers; i++) {
+			if (!(vers = prog->pg_vers[i]) || !(proc = vers->vs_proc))
+				continue;
+		for (j = 0; j < vers->vs_nproc; j++, proc++)
+			proc->pc_count = 0;
+		}
+	}
+	return opt_prt;
+}
+static  int
+rpc_proc_write(struct file *file, const char *buffer, 
+	unsigned long count, void *data)
+{
+	struct rpc_stat	*statp = (struct rpc_stat *) data;
+	struct rpc_program *prog = statp->program;
+	struct rpc_version *vers;
+	char hexnum [HEX_DIGITS];
+	unsigned int opt_prt;
+	int i, j;
+
+	opt_prt = rpc_proc_getval(hexnum, HEX_DIGITS, buffer, count);
+	if (opt_prt < 0) 
+		return opt_prt;
+
+	if (opt_prt & PRNT_NET) {
+		statp->netcnt = 0,
+		statp->netudpcnt = 0,
+		statp->nettcpcnt = 0,
+		statp->nettcpconn = 0;
+	}
+	if (opt_prt & PRNT_RPC) {
+		statp->rpccnt = 0,
+		statp->rpcretrans = 0,
+		statp->rpcauthrefresh = 0;
+	}
+	if (opt_prt & PRNT_CALLS) {
+		for (i = 0; i < prog->nrvers; i++) {
+			if (!(vers = prog->version[i]))
+				continue;
+			for (j = 0; j < vers->nrprocs; j++)
+				vers->procs[j].p_count = 0;
+		}
+	}
+	return opt_prt;
+}
+
 /*
  * Register/unregister RPC proc files
  */
 static inline struct proc_dir_entry *
 do_register(const char *name, void *data, int issvc)
 {
+	struct proc_dir_entry *res;
 	rpc_proc_init();
 	dprintk("RPC: registering /proc/net/rpc/%s\n", name);
-	return create_proc_read_entry(name, 0, proc_net_rpc, 
-				      issvc? svc_proc_read : rpc_proc_read,
-				      data);
+
+	res = create_proc_entry(name, 0666 , proc_net_rpc);
+	if (res) {
+		res->read_proc=  issvc ? svc_proc_read : rpc_proc_read;
+		res->write_proc= issvc ? svc_proc_write : rpc_proc_write;
+		res->data= data;
+	}
+	return res;
 }
 
 struct proc_dir_entry *

--------------050508010207040000070507--



-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
