From: Steve Dickson <SteveD@redhat.com>
Subject: Re: acl_extended_file() and NFS file systems
Date: Thu, 24 Jun 2004 11:23:28 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40DAF1F0.9020008@RedHat.com>
References: <40D9ABC9.1070007@moving-picture.com> <40D9C796.6000904@RedHat.com> <40D9FC0B.6050401@moving-picture.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090007040901060801040902"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdW4X-0000dg-80
	for nfs@lists.sourceforge.net; Thu, 24 Jun 2004 08:23:29 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BdW4W-0000lB-Rx
	for nfs@lists.sourceforge.net; Thu, 24 Jun 2004 08:23:28 -0700
To: James Pearson <james-p@moving-picture.com>, nfs@lists.sourceforge.net
In-Reply-To: <40D9FC0B.6050401@moving-picture.com>
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
--------------090007040901060801040902
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ok... see if the attached patch takes care of the problem...

SteveD.

--------------090007040901060801040902
Content-Type: text/plain;
 name="linux-2.4.22-nfs-unavail.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.22-nfs-unavail.patch"

--- linux-2.4.22/net/sunrpc/clnt.c.org	2004-06-24 10:49:57.000000000 -0400
+++ linux-2.4.22/net/sunrpc/clnt.c	2004-06-24 10:57:59.000000000 -0400
@@ -923,6 +923,16 @@ call_verify(struct rpc_task *task)
 		return p;
 	case RPC_GARBAGE_ARGS:
 		break;			/* retry */
+	case RPC_PROG_UNAVAIL:
+		/* report requested program number*/
+		dprintk(KERN_WARNING "RPC: unknown program\n");
+		rpc_exit(task, -ENOSYS);
+		return NULL;
+	case RPC_PROC_UNAVAIL:
+		/* report requested program and procedure number, version */
+		dprintk(KERN_WARNING "RPC: unknown procedure\n");
+		rpc_exit(task, -ENOSYS);
+		return NULL;
 	default:
 		printk(KERN_WARNING "call_verify: server accept status: %x\n", n);
 		/* Also retry */

--------------090007040901060801040902--


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
