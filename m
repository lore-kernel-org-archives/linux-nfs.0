From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: [patch] lockd control of grace period for HA NFS
Date: Mon, 29 Nov 2004 15:12:05 -0800
Message-ID: <OF18261FA7.4925FE2B-ON88256F5B.007E3E64-88256F5B.007F730F@us.ibm.com>
References: <1101341722.11478.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net,
        nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <1101341722.11478.13.camel@lade.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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


Trond Myklebust wrote on 11/24/2004 04:15:22 PM:

> So I'm an advocate of moving towards a common interface for grace period
> management for the reasons I stated in the earlier mails.

> Since the NFSv4 state model is by and large a superset of what lockd
> has, I'd argue that we should move the lockd grace stuff into the NFSv4
> interface rather than the opposite.

Here is a new patch where NFSv3/v4 grace period can be controlled (on/off).
The option was added to NFSv4 which than controls lockd grace period. V4
and lockd are now synchronized as to when they go into grace period and
they use the same period which is v4's grace period.

The next step is to remove the lockd grace period code completely and have
all the code for grace period only in nfsd, but first I wanted to make sure
that this is acceptable to you.


--- fs/lockd/svc.c.orig 2004-11-22 16:59:13.000000000 -0800
+++ fs/lockd/svc.c      2004-11-29 14:53:45.302978384 -0800
@@ -45,6 +45,7 @@ static unsigned int           nlmsvc_users;
 static pid_t                 nlmsvc_pid;
 int                    nlmsvc_grace_period;
 unsigned long                nlmsvc_timeout;
+unsigned long                grace_period_expire;

 static DECLARE_MUTEX_LOCKED(lockd_start);
 static DECLARE_WAIT_QUEUE_HEAD(lockd_exit);
@@ -95,7 +96,6 @@ lockd(struct svc_rqst *rqstp)
 {
  struct svc_serv *serv = rqstp->rq_server;
  int       err = 0;
-     unsigned long grace_period_expire;

  /* Lock module and set up kernel thread */
  /* lockd_up is waiting for us to startup, so will
@@ -349,6 +349,21 @@ nlmsvc_dispatch(struct svc_rqst *rqstp,
  return 1;
 }

+void
+lockd_grace(int on, time_t period)
+{
+
+     dprintk("lockd: lockd_grace %s period %ld\n", on ? "on" : "off",
period);
+     if (on) {
+           if (period)
+                 nlm_grace_period = period;
+           grace_period_expire = set_grace_period();
+     }
+     else {
+           clear_grace_period();
+     }
+}
+
 /*
  * Sysctl parameters (same as module parameters, different interface).
  */
--- fs/lockd/lockd_syms.c.orig      2004-11-25 16:13:04.000000000 -0800
+++ fs/lockd/lockd_syms.c     2004-11-25 16:26:45.000000000 -0800
@@ -26,6 +26,7 @@
 /* Start/stop the daemon */
 EXPORT_SYMBOL(lockd_up);
 EXPORT_SYMBOL(lockd_down);
+EXPORT_SYMBOL(lockd_grace);

 /* NFS client entry */
 EXPORT_SYMBOL(nlmclnt_proc);
--- fs/nfsd/lockd.c.orig      2004-11-24 21:57:26.000000000 -0800
+++ fs/nfsd/lockd.c     2004-11-29 12:55:35.421804152 -0800
@@ -65,9 +65,16 @@ nlm_fclose(struct file *filp)
  mntput(filp->f_vfsmnt);
 }

+static void
+nlm_grace(int on, time_t period)
+{
+     lockd_grace(on, period);
+}
+
 struct nlmsvc_binding        nfsd_nlm_ops = {
  .fopen          = nlm_fopen,            /* open file for locking */
  .fclose         = nlm_fclose,           /* close file */
+     .grace            = nlm_grace,            /* start/stop grace period
 */
 };

 void
--- fs/nfsd/nfsctl.c.orig     2004-11-24 22:29:42.000000000 -0800
+++ fs/nfsd/nfsctl.c    2004-11-29 14:45:14.352654640 -0800
@@ -24,6 +24,7 @@
 #include <linux/pagemap.h>
 #include <linux/init.h>

+#include <linux/lockd/bind.h>
 #include <linux/nfs.h>
 #include <linux/nfsd_idmap.h>
 #include <linux/sunrpc/svc.h>
@@ -36,7 +37,7 @@
 #include <asm/uaccess.h>

 /*
- *   We have a single directory with 9 nodes in it.
+ *   We have a single directory with 13 nodes in it.
  */
 enum {
  NFSD_Root = 1,
@@ -51,6 +52,7 @@ enum {
  NFSD_Fh,
  NFSD_Threads,
  NFSD_Leasetime,
+     NFSD_Grace,
 };

 /*
@@ -66,6 +68,7 @@ static ssize_t write_getfs(struct file *
 static ssize_t write_filehandle(struct file *file, char *buf, size_t
 size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
 static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
+static ssize_t toggle_grace_period(struct file *file, char *buf, size_t
size);

 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
  [NFSD_Svc] = write_svc,
@@ -78,6 +81,7 @@ static ssize_t (*write_op[])(struct file
  [NFSD_Fh] = write_filehandle,
  [NFSD_Threads] = write_threads,
  [NFSD_Leasetime] = write_leasetime,
+     [NFSD_Grace] = toggle_grace_period,
 };

 /* an argresp is stored in an allocated page and holds the
@@ -419,6 +423,34 @@ static ssize_t write_leasetime(struct fi
  return strlen(buf);
 }

+static ssize_t toggle_grace_period(struct file *file, char *buf, size_t
size)
+{
+     char *mesg = buf;
+     int rv;
+     int start;
+
+     if (size > 0) {
+           rv = get_int(&mesg, &start);
+           if (rv)
+                 return rv;
+           if (start < 0 || start > 1)
+                 return -EINVAL;
+
+           if (nlmsvc_ops && nlmsvc_ops->grace)
+                 /* use the same period for v3 and v4 */
+                 nlmsvc_ops->grace(start, nfs4_lease_time());
+           if (start) {
+                 nfs4_grace_start();
+           }
+           else {
+                 nfs4_grace_stop();
+           }
+     }
+     start = nfs4_in_grace();
+     sprintf(buf, "%d\n", start);
+     return strlen(buf);
+}
+
 /*----------------------------------------------------------------------------*/

 /*
  *   populating the filesystem.
@@ -440,6 +472,7 @@ static int nfsd_fill_super(struct super_
 #ifdef CONFIG_NFSD_V4
   [NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops,
   S_IWUSR|S_IRUSR},
 #endif
+           [NFSD_Grace] = {"grace", &transaction_ops, S_IWUSR|S_IRUSR},
   /* last one */ {""}
  };
  return simple_fill_super(sb, 0x6e667364, nfsd_files);
--- fs/nfsd/nfs4state.c.orig  2004-09-15 16:50:12.000000000 -0700
+++ fs/nfsd/nfs4state.c 2004-11-29 14:42:46.629112032 -0800
@@ -47,6 +47,7 @@
 #include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
+#include <linux/lockd/bind.h>

 #define NFSDDBG_FACILITY                NFSDDBG_PROC

@@ -2659,6 +2660,9 @@ nfs4_state_init(void)
  if (grace_time)
   printk("NFSD: starting %ld-second grace period\n", grace_time);
  grace_end = boot_time + grace_time;
+     if (nlmsvc_ops && nlmsvc_ops->grace)
+           /* use the same period for v3 and v4 */
+           nlmsvc_ops->grace(1, grace_time);
  INIT_WORK(&laundromat_work,laundromat_main, NULL);
  schedule_delayed_work(&laundromat_work, NFSD_LEASE_TIME*HZ);
  nfs4_init = 1;
@@ -2671,6 +2675,18 @@ nfs4_in_grace(void)
 }

 void
+nfs4_grace_start(void)
+{
+     grace_end = get_seconds() + nfs4_lease_time();
+}
+
+void
+nfs4_grace_stop(void)
+{
+     grace_end = get_seconds();
+}
+
+void
 set_no_grace(void)
 {
  printk("NFSD: ERROR in reboot recovery.  State reclaims will fail.\n");
--- include/linux/lockd/bind.h.orig 2004-11-24 21:49:39.000000000 -0800
+++ include/linux/lockd/bind.h      2004-11-29 12:54:03.009852904 -0800
@@ -22,6 +22,7 @@ struct nlmsvc_binding {
       struct nfs_fh *,
       struct file *);
  void                  (*fclose)(struct file *);
+     void              (*grace)(int on_off, int period);
 };

 extern struct nlmsvc_binding *     nlmsvc_ops;
@@ -32,5 +33,6 @@ extern struct nlmsvc_binding *      nlmsvc_op
 extern int nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int lockd_up(void);
 extern void      lockd_down(void);
+extern void      lockd_grace(int on_off, time_t period);

 #endif /* LINUX_LOCKD_BIND_H */
--- include/linux/nfsd/nfsd.h.orig  2004-11-25 20:53:18.000000000 -0800
+++ include/linux/nfsd/nfsd.h 2004-11-25 21:03:29.000000000 -0800
@@ -135,11 +135,15 @@ void nfs4_state_init(void);
 void nfs4_state_shutdown(void);
 time_t nfs4_lease_time(void);
 void nfs4_reset_lease(time_t leasetime);
+void nfs4_grace_start(void);
+void nfs4_grace_stop(void);
 #else
 void static inline nfs4_state_init(void){}
 void static inline nfs4_state_shutdown(void){}
 time_t static inline nfs4_lease_time(void){return 0;}
 void static inline nfs4_reset_lease(time_t leasetime){}
+void nfs4_grace_start(void){}
+void nfs4_grace_stop(void){}
 #endif

 /*



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
