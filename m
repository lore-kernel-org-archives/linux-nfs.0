Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40225 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037Ab3LPUDC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Dec 2013 15:03:02 -0500
Date: Mon, 16 Dec 2013 15:03:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: nfs-utils-1.2.9 does not play well with linux 3.10.x
Message-ID: <20131216200301.GD31816@fieldses.org>
References: <OFDD407A92.688D29A1-ONC1257C43.00634FC8-C1257C43.00645775@transmode.se>
 <20131216185419.GB31816@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131216185419.GB31816@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 16, 2013 at 01:54:19PM -0500, bfields wrote:
> On Mon, Dec 16, 2013 at 07:16:00PM +0100, Joakim Tjernlund wrote:
> > rpc.nfsd insists on adding "-4.2" when writing /proc/fs/nfsd/versions :
> >   rpc.nfsd: Writing version string to kernel: +4.1 -4.2 -2 +3 +4
> > Which causes Linux to return an EIVAL error as 3.10 has no support for 4.2 
> > and
> > does not accept any reference to 4.2
> > 
> > It seems reasonable to me that Linux should accpect -4.2 as a noop and 
> > continue
> > processing the rest of the options but I am just guessing.
> > Anyhow, just to test I applied this commit to my 3.10.24 kernel:
> >    
> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=4bdc33ed5bd9fbaa243bda6fdccb22674aed6305
> > and now it accepts the "-4.2" but I have no idea if this messes up 
> > something else.
> 
> That should be perfectly safe.
> 
> I agree that we should teach the kernel to treat "-4.x" at least as a
> no-op for unknown .x.  But nfs-utils also has to keep working with older
> kernels which don't do that.
> 
> The problem was introduced by 12a590f8d556c00a9502eeebaa763d906222d521
> "rpc.nfsd: Allow v4.2 server support with the -V option".  That should
> be using an array of ints not a bit array, so it can make the
> distinction between "off", "on", and "don't care".

So, something like this (untested).--b.

diff --git a/support/include/nfs/nfs.h b/support/include/nfs/nfs.h
index 38db5b5..df4ad76 100644
--- a/support/include/nfs/nfs.h
+++ b/support/include/nfs/nfs.h
@@ -17,7 +17,6 @@
 
 #define NFS4_MINMINOR 1
 #define NFS4_MAXMINOR 2
-#define NFS4_VERDEFAULT  0x1  /* minor verion 1 */
 
 struct nfs_fh_len {
 	int		fh_size;
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 6db92f0..a9d77ab 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -99,7 +99,7 @@ main(int argc, char **argv)
 	char *p, *progname, *port;
 	char *haddr = NULL;
 	int	socket_up = 0;
-	int minorvers = NFS4_VERDEFAULT;	/* nfsv4 minor version */
+	int minorvers[NFS4_MAXMINOR + 1] = {0};
 	unsigned int versbits = NFSCTL_VERDEFAULT;
 	unsigned int protobits = NFSCTL_ALLBITS;
 	unsigned int proto4 = 0;
@@ -164,7 +164,7 @@ main(int argc, char **argv)
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-					NFSCTL_VERUNSET(minorvers, i);
+					minorvers[i] = -1;
 					break;
 				}
 			case 3:
@@ -185,7 +185,7 @@ main(int argc, char **argv)
 						fprintf(stderr, "%s: unsupported minor version\n", optarg);
 						exit(1);
 					}
-					NFSCTL_VERSET(minorvers, i);
+					minorvers[i] = 1;
 					break;
 				}
 			case 3:
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 8b85846..1b50aba 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -269,7 +269,7 @@ nfssvc_set_sockets(const int family, const unsigned int protobits,
 }
 
 void
-nfssvc_setvers(unsigned int ctlbits, int minorvers)
+nfssvc_setvers(unsigned int ctlbits, int minorvers[])
 {
 	int fd, n, off;
 	char *ptr;
@@ -281,9 +281,9 @@ nfssvc_setvers(unsigned int ctlbits, int minorvers)
 		return;
 
 	for (n = NFS4_MINMINOR; n <= NFS4_MAXMINOR; n++) {
-		if (NFSCTL_VERISSET(minorvers, n)) 
+		if (minorvers[n] == 1)
 			off += snprintf(ptr+off, sizeof(buf) - off, "+4.%d ", n);
-		else			
+		else if (minorvers[n] == -1)
 			off += snprintf(ptr+off, sizeof(buf) - off, "-4.%d ", n);
 	}
 	for (n = NFSD_MINVERS; n <= NFSD_MAXVERS; n++) {
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 08de0fe..2bbd3d3 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -24,5 +24,5 @@ void	nfssvc_mount_nfsdfs(char *progname);
 int	nfssvc_inuse(void);
 int	nfssvc_set_sockets(const int family, const unsigned int protobits,
 			   const char *host, const char *port);
-void	nfssvc_setvers(unsigned int ctlbits, int minorvers4);
+void	nfssvc_setvers(unsigned int ctlbits, int minorvers4[]);
 int	nfssvc_threads(unsigned short port, int nrservs);
