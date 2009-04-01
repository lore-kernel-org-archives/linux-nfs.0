From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 06/47] nfsd41: Add Kconfig symbols for NFSv4.1
Date: Wed, 01 Apr 2009 17:07:42 +0300
Message-ID: <49D3752E.7060708@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229069-8636-1-git-send-email-bhalevy@panasas.com> <20090401043301.GA29339@fieldses.org> <49D32659.8040207@panasas.com> <20090401131022.GA4002@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org, steved@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30618 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932528AbZDAOIr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Apr 2009 10:08:47 -0400
In-Reply-To: <20090401131022.GA4002@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 01, 2009, 16:10 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Wed, Apr 01, 2009 at 11:31:21AM +0300, Benny Halevy wrote:
>> On Apr. 01, 2009, 7:33 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Sat, Mar 28, 2009 at 11:31:09AM +0300, Benny Halevy wrote:
>>>> Added CONFIG_NFSD_V4_1 and made it depend upon NFSD_V4 and EXPERIMENTAL
>>>> Indicate that CONFIG_NFS_V4_1 is for NFS developers at the moment
>>> Stupid question: do we need CONFIG_NFSD_V4_1 at all?  How many people
>>> will want to build a kernel with v4.0 but not v4.1?
>> That's a good question.  I'd love to get rid of it
>> and it seems like like distros, at least RH are going to have it
>> configured-in anyway.
>>
>> If the main reason to turn 4.1 support off is bugs affecting 4.0
>> then I'd much rather fix these bugs rather than hide them.
>>
>>> (And: do we have an interface that allows turning off 4.1 at run-time?
>>> That's more important than the config option.)
>> No, it's still on our todo list.  We haven't thought this completely
>> through, though.  Where would be the best place to implement that?
>> Should this be an export option or an nfsd tunable?
> 
> Imitating (or extending, if possible) nfsd/versions would be one way.
> See fs/nfsd/nfsctl.c:write_versions.  Cc'ing Steved, as I think that was
> originally his work.
> 
> --b.


Sounds great.
Here's a crude untested patch.  Does that what you mean?

Benny

git diff --stat -p
 fs/nfsd/nfs4proc.c        |    2 +-
 fs/nfsd/nfsctl.c          |   31 ++++++++++++++++++++++++++-----
 fs/nfsd/nfssvc.c          |   24 ++++++++++++++++++++++++
 include/linux/nfsd/nfsd.h |    2 ++
 4 files changed, 53 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a393d38..7619970 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -943,7 +943,7 @@ nfsd4_proc_compound(struct svc_rqst *rqstp,
 	 * According to RFC3010, this takes precedence over all other errors.
 	 */
 	status = nfserr_minor_vers_mismatch;
-	if (args->minorversion > NFSD_SUPPORTED_MINOR_VERSION)
+	if (args->minorversion > nfsd_supported_minorversion)
 		goto out;
 
 	if (!nfs41_op_ordering_ok(args)) {
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 4d63010..5fe1930 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -792,8 +792,9 @@ out_free:
 static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
-	char *vers, sign;
+	char *vers, *minorp, sign;
 	int len, num;
+	unsigned minor;
 	ssize_t tlen = 0;
 	char *sep;
 
@@ -814,9 +815,20 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 		do {
 			sign = *vers;
 			if (sign == '+' || sign == '-')
-				num = simple_strtol((vers+1), NULL, 0);
+				num = simple_strtol((vers+1), &minorp, 0);
 			else
-				num = simple_strtol(vers, NULL, 0);
+				num = simple_strtol(vers, &minorp, 0);
+			if (*minorp == '.') {
+				if (num < 4)
+					return -EINVAL;
+				minor = simple_strtoul(minorp+1, NULL, 0);
+				if (minor == 0)
+					return -EINVAL;
+				if (nfsd_minorversion(minor, sign == '-' ?
+						     NFSD_CLEAR : NFSD_SET) < 0)
+					return -EINVAL;
+				goto next;
+			}
 			switch(num) {
 			case 2:
 			case 3:
@@ -826,6 +838,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 			default:
 				return -EINVAL;
 			}
+		next:
 			vers += len + 1;
 			tlen += len;
 		} while ((len = qword_get(&mesg, vers, size)) > 0);
@@ -839,12 +852,20 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 	sep = "";
 	for (num=2 ; num <= 4 ; num++)
 		if (nfsd_vers(num, NFSD_AVAIL)) {
-			len += sprintf(buf+len, "%s%c%d", sep,
+			len += snprintf(buf+len, size-len, "%s%c%d", sep,
 				       nfsd_vers(num, NFSD_TEST)?'+':'-',
 				       num);
 			sep = " ";
 		}
-	len += sprintf(buf+len, "\n");
+	if (nfsd_vers(4, NFSD_AVAIL)) {
+		for (minor = 1; minor <= NFSD_SUPPORTED_MINOR_VERSION; minor++)
+			if (nfsd_minorversion(minor, NFSD_AVAIL)) {
+				len += snprintf(buf+len, size-len, " %c4.%u",
+					      nfsd_vers(num, NFSD_TEST)?'+':'-',
+					      minor);
+			}
+	}
+	len += snprintf(buf+len, size-len, "\n");
 	return len;
 }
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6ec29c7..5f4cecb 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -121,6 +121,8 @@ struct svc_program		nfsd_program = {
 
 };
 
+u32 nfsd_supported_minorversion = NFSD_SUPPORTED_MINOR_VERSION;
+
 int nfsd_vers(int vers, enum vers_op change)
 {
 	if (vers < NFSD_MINVERS || vers >= NFSD_NRVERS)
@@ -147,6 +149,28 @@ int nfsd_vers(int vers, enum vers_op change)
 	}
 	return 0;
 }
+
+int nfsd_minorversion(u32 minorversion, enum vers_op change)
+{
+	if (minorversion > NFSD_SUPPORTED_MINOR_VERSION)
+		return -1;
+	switch(change) {
+	case NFSD_SET:
+		nfsd_supported_minorversion = minorversion;
+		break;
+	case NFSD_CLEAR:
+		if (minorversion == 0)
+			return -1;
+		nfsd_supported_minorversion = minorversion - 1;
+		break;
+	case NFSD_TEST:
+		return minorversion <= nfsd_supported_minorversion;
+	case NFSD_AVAIL:
+		return minorversion <= NFSD_SUPPORTED_MINOR_VERSION;
+	}
+	return 0;
+}
+
 /*
  * Maximum number of nfsd processes
  */
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index b9e6682..27b9cf5 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -57,6 +57,7 @@ typedef int (*nfsd_dirop_t)(struct inode *, struct dentry *, int, int);
 extern struct svc_program	nfsd_program;
 extern struct svc_version	nfsd_version2, nfsd_version3,
 				nfsd_version4;
+extern u32			nfsd_supported_minorversion;
 extern struct mutex		nfsd_mutex;
 extern struct svc_serv		*nfsd_serv;
 
@@ -153,6 +154,7 @@ int nfsd_set_posix_acl(struct svc_fh *, int, struct posix_acl *);
 
 enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
 int nfsd_vers(int vers, enum vers_op change);
+int nfsd_minorversion(u32 minorversion, enum vers_op change);
 void nfsd_reset_versions(void);
 int nfsd_create_serv(void);
 

