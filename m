From: Marc Eshel <eshel@almaden.ibm.com>
Subject: [patch] lockd control of grace period for HA NFS
Date: Tue, 23 Nov 2004 19:38:34 -0800
Message-ID: <OFB81726D4.627FD14C-ON88256F56.0010B138-88256F56.001402F0@us.ibm.com>
References: <16802.32693.974799.504191@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWo4S-0000V4-8C
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 19:43:56 -0800
Received: from e5.ny.us.ibm.com ([32.97.182.105])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CWo4L-00020i-CG
	for nfs@lists.sourceforge.net; Tue, 23 Nov 2004 19:43:55 -0800
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAO3hbHt539770
	for <nfs@lists.sourceforge.net>; Tue, 23 Nov 2004 22:43:37 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAO3hbXb283174
	for <nfs@lists.sourceforge.net>; Tue, 23 Nov 2004 22:43:37 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAO3haNT006441
	for <nfs@lists.sourceforge.net>; Tue, 23 Nov 2004 22:43:37 -0500
In-Reply-To: <16802.32693.974799.504191@cse.unsw.edu.au>
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Hi Neil

Can you please consider adding this patch to lockd which is can be very
helpful for HA NFS.
HA NFS server have to block NLM lock requests on all machines in the
cluster while they recover or failover one of the machines in the cluster.
The following patch will allow NFS server machine on which there was no
failure to go into grace period just to block new lock request until the IP
of the failing node is transferred to another node in the cluster. Only the
clients of the failing node will have to do reclaims their locks.
'echo 1 > /porc/sys/fs/nfs/nlm_grace' will put lockd in grace period and
'echo 0 > /porc/sys/fs/nfs/nlm_grace' will take it out of grace period but
it is not necessary to 'echo 0' since it will just come out of grace period
when the period ends.

Thanks, Marc.



--- fs/lockd/svc.c.orig 2004-11-22 16:59:13.000000000 -0800
+++ fs/lockd/svc.c      2004-11-23 17:15:18.980522064 -0800
@@ -45,6 +45,7 @@ static unsigned int           nlmsvc_users;
 static pid_t                 nlmsvc_pid;
 int                          nlmsvc_grace_period;
 unsigned long                nlmsvc_timeout;
+unsigned long                grace_period_expire;

 static DECLARE_MUTEX_LOCKED(lockd_start);
 static DECLARE_WAIT_QUEUE_HEAD(lockd_exit);
@@ -53,6 +54,7 @@ static DECLARE_WAIT_QUEUE_HEAD(lockd_exi
  * These can be set at insmod time (useful for NFS as root filesystem),
  * and also changed through the sysctl interface.  -- Jamie Lokier, Aug
  2003
  */
+static int                   nlm_grace;
 static unsigned long         nlm_grace_period;
 static unsigned long         nlm_timeout = LOCKD_DFLT_TIMEO;
 static int             nlm_udpport, nlm_tcpport;
@@ -62,6 +64,8 @@ static int              nlm_udpport, nlm_tcpport;
  */
 static const unsigned long   nlm_grace_period_min = 0;
 static const unsigned long   nlm_grace_period_max = 240;
+static const int       nlm_grace_min = 0;
+static const int       nlm_grace_max = 1;
 static const unsigned long   nlm_timeout_min = 3;
 static const unsigned long   nlm_timeout_max = 20;
 static const int       nlm_port_min = 0, nlm_port_max = 65535;
@@ -95,7 +99,6 @@ lockd(struct svc_rqst *rqstp)
 {
  struct svc_serv *serv = rqstp->rq_server;
  int       err = 0;
-     unsigned long grace_period_expire;

  /* Lock module and set up kernel thread */
  /* lockd_up is waiting for us to startup, so will
@@ -349,6 +352,28 @@ nlmsvc_dispatch(struct svc_rqst *rqstp,
  return 1;
 }

+int lockd_toggle_grace(ctl_table *table, int write, struct file *filp,
+                  void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+     int rc;
+
+     if (!write)
+           nlm_grace = nlmsvc_grace_period;
+
+     rc = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
+     if (rc)
+           return rc;
+
+     if (write) {
+           dprintk("lockd: grace period %s\n", nlm_grace ? "on" : "off");
+           if (nlm_grace)
+                 grace_period_expire = set_grace_period();
+           else
+                 clear_grace_period();
+     }
+     return 0;
+}
+
 /*
  * Sysctl parameters (same as module parameters, different interface).
  */
@@ -369,6 +394,16 @@ static ctl_table nlm_sysctls[] = {
  },
  {
   .ctl_name      = CTL_UNNUMBERED,
+           .procname   = "nlm_grace",
+           .data       = &nlm_grace,
+           .maxlen           = sizeof(int),
+           .mode       = 0644,
+           .proc_handler     = &lockd_toggle_grace,
+           .extra1           = (int *) &nlm_grace_min,
+           .extra2           = (int *) &nlm_grace_max,
+     },
+     {
+           .ctl_name   = CTL_UNNUMBERED,
   .procname      = "nlm_timeout",
   .data          = &nlm_timeout,
   .maxlen        = sizeof(int),



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
