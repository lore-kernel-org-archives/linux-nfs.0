Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:60873 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933217Ab0HFBhh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Aug 2010 21:37:37 -0400
Message-Id: <201008060137.o761bJds093695@www262.sakura.ne.jp>
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Date: Fri, 06 Aug 2010 10:37:19 +0900
References: <201008020747.o727lqXs064715@www262.sakura.ne.jp> <20100802103214.7eea09eb@corrin.poochiereds.net> <20100802103620.5638dac1@corrin.poochiereds.net> <20100802181634.GD12637@fieldses.org> <201008030109.o73193bp094241@www262.sakura.ne.jp> <20100803154851.GA23467@fieldses.org> <201008040013.o740DmYK024832@www262.sakura.ne.jp> <20100804194045.GD18200@fieldses.org> <201008050110.o751AG18066496@www262.sakura.ne.jp> <20100805204612.GA13821@fieldses.org> <20100805213107.GB13821@fieldses.org>
In-Reply-To: <20100805213107.GB13821@fieldses.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I compared using below patch.

 fs/nfsd/nfssvc.c |   11 +++++++++++
 net/sunrpc/svc.c |   12 ++++++++++++
 2 files changed, 23 insertions(+)

--- linux-2.6.35-next.orig/fs/nfsd/nfssvc.c
+++ linux-2.6.35-next/fs/nfsd/nfssvc.c
@@ -263,15 +263,26 @@ void nfsd_reset_versions(void)
 	int found_one = 0;
 	int i;
 
+	printk(KERN_INFO "***** %s is called *****.\n", __func__);
 	for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++) {
 		if (nfsd_program.pg_vers[i])
 			found_one = 1;
 	}
 
+	printk(KERN_INFO "***** found_one=%u *****.\n", found_one);
 	if (!found_one) {
+		printk(KERN_INFO
+		       "***** &nfsd_program=%p nfsd_version=%p *****.\n",
+		       &nfsd_program, nfsd_version);
+		printk(KERN_INFO
+		       "***** NFSD_MINVERS=%u NFSD_NRVERS=%u *****.\n",
+		       NFSD_MINVERS, NFSD_NRVERS);
 		for (i = NFSD_MINVERS; i < NFSD_NRVERS; i++)
 			nfsd_program.pg_vers[i] = nfsd_version[i];
 #if defined(CONFIG_NFSD_V2_ACL) || defined(CONFIG_NFSD_V3_ACL)
+		printk(KERN_INFO
+		       "***** NFSD_ACL_MINVERS=%u NFSD_ACL_NRVERS=%u *****.\n",
+		       NFSD_ACL_MINVERS, NFSD_ACL_NRVERS);
 		for (i = NFSD_ACL_MINVERS; i < NFSD_ACL_NRVERS; i++)
 			nfsd_acl_program.pg_vers[i] =
 				nfsd_acl_version[i];
--- linux-2.6.35-next.orig/net/sunrpc/svc.c
+++ linux-2.6.35-next/net/sunrpc/svc.c
@@ -379,7 +379,9 @@ __svc_create(struct svc_program *prog, u
 	serv->sv_max_mesg  = roundup(serv->sv_max_payload + PAGE_SIZE, PAGE_SIZE);
 	serv->sv_shutdown  = shutdown;
 	xdrsize = 0;
+	printk(KERN_INFO "***** %s is called. *****\n", __func__);
 	while (prog) {
+		printk(KERN_INFO "***** prog=%p *****\n", prog);
 		prog->pg_lovers = prog->pg_nvers-1;
 		for (vers=0; vers<prog->pg_nvers ; vers++)
 			if (prog->pg_vers[vers]) {
@@ -389,8 +391,13 @@ __svc_create(struct svc_program *prog, u
 				if (prog->pg_vers[vers]->vs_xdrsize > xdrsize)
 					xdrsize = prog->pg_vers[vers]->vs_xdrsize;
 			}
+			else
+				printk(KERN_INFO
+				       "***** prog->pg_vers[%u]=NULL *****\n",
+				       vers);
 		prog = prog->pg_next;
 	}
+	printk(KERN_INFO "***** xdrsize=%u *****\n", xdrsize);
 	serv->sv_xdrsize   = xdrsize;
 	INIT_LIST_HEAD(&serv->sv_tempsocks);
 	INIT_LIST_HEAD(&serv->sv_permsocks);
@@ -1084,6 +1091,11 @@ svc_process_common(struct svc_rqst *rqst
 	procp->pc_count++;
 
 	/* Initialize storage for argp and resp */
+	printk(KERN_INFO "rqstp=%p procp=%p\n", rqstp, procp);
+	printk(KERN_INFO "rqstp->rq_argp=%p procp->pc_argsize=%u\n",
+	       rqstp->rq_argp, procp->pc_argsize);
+	printk(KERN_INFO "rqstp->rq_resp=%p procp->pc_ressize=%u\n",
+	       rqstp->rq_resp, procp->pc_ressize);
 	memset(rqstp->rq_argp, 0, procp->pc_argsize);
 	memset(rqstp->rq_resp, 0, procp->pc_ressize);
 

--- 2.6.35 ---

Booting.

[   27.086953] ifconfig used greatest stack depth: 1364 bytes left
[   27.255143] pcnet32 0000:02:00.0: eth0: link up
[   35.976256] mv used greatest stack depth: 1052 bytes left
[   37.993094] ***** nfsd_reset_versions is called *****.
[   37.995126] ***** found_one=0 *****.
[   37.996103] ***** &nfsd_program=c1540780 nfsd_version=c1540770 *****.
[   38.018003] ***** NFSD_MINVERS=2 NFSD_NRVERS=4 *****.
[   38.019387] ***** __svc_create is called. *****
[   38.020496] ***** prog=c1540780 *****
[   38.021391] ***** prog->pg_vers[0]=NULL *****
[   38.022425] ***** prog->pg_vers[1]=NULL *****
[   38.023470] ***** xdrsize=544 *****
[   38.069845] ***** __svc_create is called. *****
[   38.070957] ***** prog=c1541a00 *****
[   38.071844] ***** prog->pg_vers[0]=NULL *****
[   38.072883] ***** prog->pg_vers[2]=NULL *****
[   38.073941] ***** xdrsize=344 *****
[   38.149718] NET: Registered protocol family 10
[   38.588799] svc: failed to register lockdv1 RPC service (errno 97).
[   38.664394] rqstp=dc81f000 procp=c1541220
[   38.665395] rqstp->rq_argp=dcb93bf0 procp->pc_argsize=4
[   38.666621] rqstp->rq_resp=dcb94bf0 procp->pc_ressize=4
[   40.129085] ***** nfsd_reset_versions is called *****.
[   40.130336] ***** found_one=1 *****.

Doing "mount 127.0.0.1:/usr/src/ /mnt/".

[   75.786438] rqstp=de136000 procp=c1541220
[   75.787464] rqstp->rq_argp=dc81abf0 procp->pc_argsize=4
[   75.788681] rqstp->rq_resp=dc850bf0 procp->pc_ressize=4
[   75.792740] rqstp=de136000 procp=c15414cc
[   75.793701] rqstp->rq_argp=dc81abf0 procp->pc_argsize=264
[   75.815618] rqstp->rq_resp=dc850bf0 procp->pc_ressize=44
[   75.825175] rqstp=de136000 procp=c1541244
[   75.847017] rqstp->rq_argp=dc81abf0 procp->pc_argsize=264
[   75.848320] rqstp->rq_resp=dc850bf0 procp->pc_ressize=344
[   75.854935] rqstp=de136000 procp=c15414cc
[   75.855983] rqstp->rq_argp=dc81abf0 procp->pc_argsize=264
[   75.877639] rqstp->rq_resp=dc850bf0 procp->pc_ressize=44
[   75.879404] rqstp=de136000 procp=c1541244
[   75.880366] rqstp->rq_argp=dc81abf0 procp->pc_argsize=264
[   75.881639] rqstp->rq_resp=dc850bf0 procp->pc_ressize=344

--- 2.6.35-next-20100802 + 3deb279d6e5625407919a875db3a2461199566b3 ---

Booting.

[   26.414571] ifconfig used greatest stack depth: 1028 bytes left
[   26.587372] pcnet32 0000:02:00.0: eth0: link up
[   36.854504] ***** __svc_create is called. *****
[   36.861266] ***** prog=c154c760 *****
[   36.862180] ***** prog->pg_vers[0]=NULL *****
[   36.863221] ***** prog->pg_vers[1]=NULL *****
[   36.864255] ***** prog->pg_vers[2]=NULL *****
[   36.865284] ***** prog->pg_vers[3]=NULL *****
[   36.866356] ***** xdrsize=0 *****
[   36.874007] ***** __svc_create is called. *****
[   36.875094] ***** prog=c154da00 *****
[   36.875978] ***** prog->pg_vers[0]=NULL *****
[   36.877017] ***** prog->pg_vers[2]=NULL *****
[   36.878063] ***** xdrsize=344 *****
[   36.992851] NET: Registered protocol family 10
[   37.416006] svc: failed to register lockdv1 RPC service (errno 97).
[   37.419146] ***** nfsd_reset_versions is called *****.
[   37.420383] ***** found_one=0 *****.
[   37.421255] ***** &nfsd_program=c154c760 nfsd_version=c154c750 *****.
[   37.422776] ***** NFSD_MINVERS=2 NFSD_NRVERS=4 *****.

Doing "mount 127.0.0.1:/usr/src/ /mnt/".

[   58.947605] rqstp=dcfb2000 procp=c154ca20
[   58.948668] rqstp->rq_argp=00000010 procp->pc_argsize=4
[   58.949976] rqstp->rq_resp=00000010 procp->pc_ressize=4
[   58.951520] BUG: unable to handle kernel NULL pointer dereference at 00000010
[   58.953374] IP: [<c1356f20>] svc_process_common+0x370/0x640


J. Bruce Fields wrote:
> OK, I think it's another startup-order problem: depending on how things
> are started up, sv_nrthreads may already be nonzero, causing us to skip
> nfsd_reset_versions(), so that the loop in __svc_create() ends up
> leaving xdrsize 0, and then the kmalloc's in svc_prepare_thread() assign
> ZERO_SIZE_PTR.

Indeed.
Regarding 2.6.35, nfsd_reset_versions() is called before __svc_create() is
called and xdrsize != 0. But regarding 2.6.35-next-20100802 +
3deb279d6e5625407919a875db3a2461199566b3, __svc_create() is called before
nfsd_reset_versions() is called and xdrsize == 0.
