From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: NULL-terminate buffer after read in
	read_service_info (try #2)
Date: Tue, 10 Mar 2009 12:18:10 -0400
Message-ID: <1236701890-9111-1-git-send-email-jlayton@redhat.com>
References: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: steved@redhat.com
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Valgrind complains that we're passing an unintialized buffer to sscanf
here. The main problem seems to be that we're not ensuring that the
buffer is NULL terminated before we pass it off.

This is the second version of this patch, the first one did not increase
the buffer allocation by 1 which could have led to clobbering the next
byte on the stack if nbytes == INFOBUFLEN.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 295c37d..fb97a13 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -107,7 +107,7 @@ static int
 read_service_info(char *info_file_name, char **servicename, char **servername,
 		  int *prog, int *vers, char **protocol, int *port) {
 #define INFOBUFLEN 256
-	char		buf[INFOBUFLEN];
+	char		buf[INFOBUFLEN + 1];
 	static char	dummy[128];
 	int		nbytes;
 	static char	service[128];
@@ -132,6 +132,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	if ((nbytes = read(fd, buf, INFOBUFLEN)) == -1)
 		goto fail;
 	close(fd);
+	buf[nbytes] = '\0';
 
 	numfields = sscanf(buf,"RPC server: %127s\n"
 		   "service: %127s %15s version %15s\n"
-- 
1.6.0.6
