From: Steve Dickson <SteveD@redhat.com>
Subject: Re: lockd recovery not working on RH with 2.6 kernel
Date: Thu, 18 Nov 2004 11:52:19 -0500
Message-ID: <419CD343.4000600@RedHat.com>
References: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010205020605080301090606"
Cc: NFS@lists.sourceforge.net, Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <OF573E8465.7E3D5CC0-ON88256F49.0064BB5C-88256F49.00698B56@us.ibm.com>
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

This is a multi-part message in MIME format.
--------------010205020605080301090606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hey Trond,

Marc Eshel wrote:

>The problem is that after the NFS sever machine reboots its statd sends a
>notification to all NFS clients that had locking activity but the clients
>fail to reclaim their locks.
>  
>
Well it appears things are a bit broken. Here is a client side patch that
enables the client to reclaim locks on a rebooted server.

The two main issues were nlm4svc_decode_reboot() not setting
the protocol which cause the nlm_host structure not to be found
and two, making nlmclnt_reclaim() retry when the portmapper was up
but lockd had not made it yet.... I also fixed a debugging
statement and well as added a couple... that I found useful....

Now the reclaim retry code currently retries forever in an
interruptible loop waiting for lockd to come up. This may or
may not be a good idea, but the client should not make any
assumptions about the health of the server, to I'm not sure there
is anything else that can be done....

Unfortunately this reclaim code freaks out the linux server, causing it
to send two back-to-back messages (both using the same xid) that
fails and then grant the lock.... It seems the dentry_open() call
(in nfsd_open()) is returning 30000 error value. Its not clear why or
what a 30000 value means....  I'm still looking in to that, but this code
was tested with both a Neapps filer and Solaris 10 server which seem
to work fine..

Comments? 

SteveD.

--------------010205020605080301090606
Content-Type: text/x-patch;
 name="linux-2.6.9-lockd-reclaims.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.9-lockd-reclaims.patch"

--- linux-2.6.9/fs/lockd/xdr4.c.org	2004-10-18 17:53:06.000000000 -0400
+++ linux-2.6.9/fs/lockd/xdr4.c	2004-11-18 10:44:27.324666000 -0500
@@ -355,6 +355,9 @@ nlm4svc_decode_reboot(struct svc_rqst *r
 	argp->state = ntohl(*p++);
 	/* Preserve the address in network byte order */
 	argp->addr = *p++;
+	argp->vers = *p++;
+	argp->proto = *p++;
+
 	return xdr_argsize_check(rqstp, p);
 }
 
--- linux-2.6.9/fs/lockd/clntlock.c.org	2004-11-12 05:43:13.508648000 -0500
+++ linux-2.6.9/fs/lockd/clntlock.c	2004-11-18 07:57:33.464093000 -0500
@@ -173,7 +173,7 @@ void nlmclnt_prepare_reclaim(struct nlm_
 	host->h_nextrebind = 0;
 	nlm_rebind_host(host);
 	nlmclnt_mark_reclaim(host);
-	dprintk("NLM: reclaiming locks for host %s", host->h_name);
+	dprintk("NLM: reclaiming locks for host %s\n", host->h_name);
 }
 
 /*
--- linux-2.6.9/fs/lockd/host.c.org	2004-10-18 17:54:31.000000000 -0400
+++ linux-2.6.9/fs/lockd/host.c	2004-11-18 07:58:26.263774000 -0500
@@ -190,15 +190,17 @@ nlm_bind_host(struct nlm_host *host)
 		}
 	} else {
 		xprt = xprt_create_proto(host->h_proto, &host->h_addr, NULL);
-		if (IS_ERR(xprt))
+		if (IS_ERR(xprt)) {
+			dprintk("lockd: xprt_create_proto failed: %ld\n", PTR_ERR(xprt));
 			goto forgetit;
-
+		}
 		xprt_set_timeout(&xprt->timeout, 5, nlmsvc_timeout);
 
 		clnt = rpc_create_client(xprt, host->h_name, &nlm_program,
 					host->h_version, host->h_authflavor);
 		if (IS_ERR(clnt)) {
 			xprt_destroy(xprt);
+			dprintk("lockd: rpc_create_client failed: %ld\n", PTR_ERR(clnt));
 			goto forgetit;
 		}
 		clnt->cl_autobind = 1;	/* turn on pmap queries */
--- linux-2.6.9/fs/lockd/clntproc.c.org	2004-10-18 17:55:36.000000000 -0400
+++ linux-2.6.9/fs/lockd/clntproc.c	2004-11-18 08:02:36.787274000 -0500
@@ -592,9 +592,25 @@ nlmclnt_reclaim(struct nlm_host *host, s
 	nlmclnt_setlockargs(req, fl);
 	req->a_args.reclaim = 1;
 
-	if ((status = nlmclnt_call(req, NLMPROC_LOCK)) >= 0
-	 && req->a_res.status == NLM_LCK_GRANTED)
-		return 0;
+again:
+	switch ((status = nlmclnt_call(req, NLMPROC_LOCK))) {
+	case 0:
+		if (req->a_res.status == NLM_LCK_GRANTED)
+			return 0;
+		break;
+	case -EAGAIN:
+	case -EACCES: /* portmapper might be up, but lockd isn't */
+		current->state = TASK_INTERRUPTIBLE;
+		schedule_timeout(10*HZ);
+		if (signalled()) {
+			status = -EINTR;
+			dprintk("lockd: reclaim got interrupted!\n");
+			break;
+		}
+		goto again;
+	default:
+		break;
+	}
 
 	printk(KERN_WARNING "lockd: failed to reclaim lock for pid %d "
 				"(errno %d, status %d)\n", fl->fl_pid,

--------------010205020605080301090606--


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
