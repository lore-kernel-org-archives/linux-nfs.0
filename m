From: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: RFC/Patch: Make NFS Readahead tunable
Date: Tue, 15 Apr 2008 06:39:37 -0700 (PDT)
Message-ID: <975253.58176.qm@web32607.mail.mud.yahoo.com>
Reply-To: Martin Knoblauch <spamtrap-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-2033192147-1208266777=:58176"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
To: linux-nfs list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32607.mail.mud.yahoo.com ([68.142.207.234]:26128 "HELO
	web32607.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754662AbYDONqS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2008 09:46:18 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--0-2033192147-1208266777=:58176
Content-Type: text/plain; charset=us-ascii

Hi,

 while tracking down a very interesting interaction between Sun/SAM-FS and Linux NFS clients, we found out that the value of NFS_MAX_READ_AHEAD is to agressive/big for the specific use-case.

 For testing, instead of always recompiling the kernel with different values, I came up with the following patch. It introduces a tunable  "/proc/sys/fs/nfs/nfs_ra_factor" with possible values between 0-15.

 Not sure whether it is actually a good thing to have. Better would be to set the read-ahead factor per filesystem via a mount option.

 The patch is against 2.6.24. It applies with offsets against 2.6.25-rc9. In case my mail client messes up the whitespace, the patch is also attached.

Signed-off-by: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>

diff -ru linux-2.6.24-orig/fs/nfs/client.c linux-2.6.24-nfs_ra/fs/nfs/client.c
--- linux-2.6.24-orig/fs/nfs/client.c   2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24-nfs_ra/fs/nfs/client.c 2008-04-14 16:44:22.000000000 +0200
@@ -601,6 +601,11 @@
 }

 /*
+ * NFS Client Read-Ahead factor
+*/
+unsigned int nfs_ra_factor;
+
+/*
  * Load up the server record from information gained in an fsinfo record
  */
 static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *fsinfo)
@@ -625,7 +630,9 @@
                server->rsize = NFS_MAX_FILE_IO_SIZE;
        server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;

-       server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
+       printk(KERN_INFO "nfs_server_set_fsinfo: rsize, wsize, rpages, nfs_ra_factor, ra_pages: %d %d %d %d %d\n",
+               server->rsize,server->wsize,server->rpages,nfs_ra_factor,server->rpages * nfs_ra_factor);
+       server->backing_dev_info.ra_pages = server->rpages * nfs_ra_factor;

        if (server->wsize > max_rpc_payload)
                server->wsize = max_rpc_payload;
@@ -1359,6 +1366,8 @@
 {
        struct proc_dir_entry *p;

+       nfs_ra_factor = NFS_MAX_READAHEAD;
+
        proc_fs_nfs = proc_mkdir("nfsfs", proc_root_fs);
        if (!proc_fs_nfs)
                goto error_0;
diff -ru linux-2.6.24-orig/fs/nfs/sysctl.c linux-2.6.24-nfs_ra/fs/nfs/sysctl.c
--- linux-2.6.24-orig/fs/nfs/sysctl.c   2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24-nfs_ra/fs/nfs/sysctl.c 2008-04-14 16:15:03.000000000 +0200
@@ -14,9 +14,12 @@
 #include <linux/nfs_fs.h>

 #include "callback.h"
+#include "internal.h"

 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
+static const unsigned int min_nfs_ra_factor = 0;
+static const unsigned int max_nfs_ra_factor = NFS_MAX_READAHEAD;
 static struct ctl_table_header *nfs_callback_sysctl_table;

 static ctl_table nfs_cb_sysctls[] = {
@@ -58,6 +61,16 @@
                .mode           = 0644,
                .proc_handler   = &proc_dointvec,
        },
+       {
+               .ctl_name = CTL_UNNUMBERED,
+               .procname = "nfs_ra_factor",
+               .data = &nfs_ra_factor,
+               .maxlen = sizeof(unsigned int),
+               .mode = 0644,
+               .proc_handler = &proc_dointvec_minmax,
+               .extra1 = (unsigned int *)&min_nfs_ra_factor,
+               .extra2 = (unsigned int *)&max_nfs_ra_factor,
+       },
        { .ctl_name = 0 }
 };

diff -ru linux-2.6.24-orig/include/linux/nfs_fs.h linux-2.6.24-nfs_ra/include/linux/nfs_fs.h
--- linux-2.6.24-orig/include/linux/nfs_fs.h    2008-01-24 23:58:37.000000000 +0100
+++ linux-2.6.24-nfs_ra/include/linux/nfs_fs.h  2008-04-14 15:58:57.000000000 +0200
@@ -415,6 +415,11 @@
 extern void nfs_writedata_release(void *);

 /*
+ * linux/fs/nfs/client.c
+*/
+extern unsigned int nfs_ra_factor;
+
+/*
  * Try to write back everything synchronously (but check the
  * return value!)
  */


Cheers
 Martin
------------------------------------------------------
Martin Knoblauch
email: k n o b i AT knobisoft DOT de
www:   http://www.knobisoft.de



--0-2033192147-1208266777=:58176
Content-Type: text/x-patch; name="nfs_ra-2.6.24.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="nfs_ra-2.6.24.patch"

ZGlmZiAtcnUgbGludXgtMi42LjI0LW9yaWcvZnMvbmZzL2NsaWVudC5jIGxp
bnV4LTIuNi4yNC1uZnNfcmEvZnMvbmZzL2NsaWVudC5jCi0tLSBsaW51eC0y
LjYuMjQtb3JpZy9mcy9uZnMvY2xpZW50LmMJMjAwOC0wMS0yNCAyMzo1ODoz
Ny4wMDAwMDAwMDAgKzAxMDAKKysrIGxpbnV4LTIuNi4yNC1uZnNfcmEvZnMv
bmZzL2NsaWVudC5jCTIwMDgtMDQtMTQgMTY6NDQ6MjIuMDAwMDAwMDAwICsw
MjAwCkBAIC02MDEsNiArNjAxLDExIEBACiB9CiAKIC8qCisgKiBORlMgQ2xp
ZW50IFJlYWQtQWhlYWQgZmFjdG9yCisqLwordW5zaWduZWQgaW50IG5mc19y
YV9mYWN0b3I7CisKKy8qCiAgKiBMb2FkIHVwIHRoZSBzZXJ2ZXIgcmVjb3Jk
IGZyb20gaW5mb3JtYXRpb24gZ2FpbmVkIGluIGFuIGZzaW5mbyByZWNvcmQK
ICAqLwogc3RhdGljIHZvaWQgbmZzX3NlcnZlcl9zZXRfZnNpbmZvKHN0cnVj
dCBuZnNfc2VydmVyICpzZXJ2ZXIsIHN0cnVjdCBuZnNfZnNpbmZvICpmc2lu
Zm8pCkBAIC02MjUsNyArNjMwLDkgQEAKIAkJc2VydmVyLT5yc2l6ZSA9IE5G
U19NQVhfRklMRV9JT19TSVpFOwogCXNlcnZlci0+cnBhZ2VzID0gKHNlcnZl
ci0+cnNpemUgKyBQQUdFX0NBQ0hFX1NJWkUgLSAxKSA+PiBQQUdFX0NBQ0hF
X1NISUZUOwogCi0Jc2VydmVyLT5iYWNraW5nX2Rldl9pbmZvLnJhX3BhZ2Vz
ID0gc2VydmVyLT5ycGFnZXMgKiBORlNfTUFYX1JFQURBSEVBRDsKKwlwcmlu
dGsoS0VSTl9JTkZPICJuZnNfc2VydmVyX3NldF9mc2luZm86IHJzaXplLCB3
c2l6ZSwgcnBhZ2VzLCBuZnNfcmFfZmFjdG9yLCByYV9wYWdlczogJWQgJWQg
JWQgJWQgJWRcbiIsCisJCXNlcnZlci0+cnNpemUsc2VydmVyLT53c2l6ZSxz
ZXJ2ZXItPnJwYWdlcyxuZnNfcmFfZmFjdG9yLHNlcnZlci0+cnBhZ2VzICog
bmZzX3JhX2ZhY3Rvcik7CisJc2VydmVyLT5iYWNraW5nX2Rldl9pbmZvLnJh
X3BhZ2VzID0gc2VydmVyLT5ycGFnZXMgKiBuZnNfcmFfZmFjdG9yOwogCiAJ
aWYgKHNlcnZlci0+d3NpemUgPiBtYXhfcnBjX3BheWxvYWQpCiAJCXNlcnZl
ci0+d3NpemUgPSBtYXhfcnBjX3BheWxvYWQ7CkBAIC0xMzU5LDYgKzEzNjYs
OCBAQAogewogCXN0cnVjdCBwcm9jX2Rpcl9lbnRyeSAqcDsKIAorCW5mc19y
YV9mYWN0b3IgPSBORlNfTUFYX1JFQURBSEVBRDsKKwogCXByb2NfZnNfbmZz
ID0gcHJvY19ta2RpcigibmZzZnMiLCBwcm9jX3Jvb3RfZnMpOwogCWlmICgh
cHJvY19mc19uZnMpCiAJCWdvdG8gZXJyb3JfMDsKZGlmZiAtcnUgbGludXgt
Mi42LjI0LW9yaWcvZnMvbmZzL3N5c2N0bC5jIGxpbnV4LTIuNi4yNC1uZnNf
cmEvZnMvbmZzL3N5c2N0bC5jCi0tLSBsaW51eC0yLjYuMjQtb3JpZy9mcy9u
ZnMvc3lzY3RsLmMJMjAwOC0wMS0yNCAyMzo1ODozNy4wMDAwMDAwMDAgKzAx
MDAKKysrIGxpbnV4LTIuNi4yNC1uZnNfcmEvZnMvbmZzL3N5c2N0bC5jCTIw
MDgtMDQtMTQgMTY6MTU6MDMuMDAwMDAwMDAwICswMjAwCkBAIC0xNCw5ICsx
NCwxMiBAQAogI2luY2x1ZGUgPGxpbnV4L25mc19mcy5oPgogCiAjaW5jbHVk
ZSAiY2FsbGJhY2suaCIKKyNpbmNsdWRlICJpbnRlcm5hbC5oIgogCiBzdGF0
aWMgY29uc3QgaW50IG5mc19zZXRfcG9ydF9taW4gPSAwOwogc3RhdGljIGNv
bnN0IGludCBuZnNfc2V0X3BvcnRfbWF4ID0gNjU1MzU7CitzdGF0aWMgY29u
c3QgdW5zaWduZWQgaW50IG1pbl9uZnNfcmFfZmFjdG9yID0gMDsKK3N0YXRp
YyBjb25zdCB1bnNpZ25lZCBpbnQgbWF4X25mc19yYV9mYWN0b3IgPSBORlNf
TUFYX1JFQURBSEVBRDsKIHN0YXRpYyBzdHJ1Y3QgY3RsX3RhYmxlX2hlYWRl
ciAqbmZzX2NhbGxiYWNrX3N5c2N0bF90YWJsZTsKIAogc3RhdGljIGN0bF90
YWJsZSBuZnNfY2Jfc3lzY3Rsc1tdID0gewpAQCAtNTgsNiArNjEsMTYgQEAK
IAkJLm1vZGUJCT0gMDY0NCwKIAkJLnByb2NfaGFuZGxlcgk9ICZwcm9jX2Rv
aW50dmVjLAogCX0sCisJeworCQkuY3RsX25hbWUgPSBDVExfVU5OVU1CRVJF
RCwKKwkJLnByb2NuYW1lID0gIm5mc19yYV9mYWN0b3IiLAorCQkuZGF0YSA9
ICZuZnNfcmFfZmFjdG9yLAorCQkubWF4bGVuID0gc2l6ZW9mKHVuc2lnbmVk
IGludCksCisJCS5tb2RlID0gMDY0NCwKKwkJLnByb2NfaGFuZGxlciA9ICZw
cm9jX2RvaW50dmVjX21pbm1heCwKKwkJLmV4dHJhMSA9ICh1bnNpZ25lZCBp
bnQgKikmbWluX25mc19yYV9mYWN0b3IsCisJCS5leHRyYTIgPSAodW5zaWdu
ZWQgaW50ICopJm1heF9uZnNfcmFfZmFjdG9yLAorCX0sCiAJeyAuY3RsX25h
bWUgPSAwIH0KIH07CiAKZGlmZiAtcnUgbGludXgtMi42LjI0LW9yaWcvaW5j
bHVkZS9saW51eC9uZnNfZnMuaCBsaW51eC0yLjYuMjQtbmZzX3JhL2luY2x1
ZGUvbGludXgvbmZzX2ZzLmgKLS0tIGxpbnV4LTIuNi4yNC1vcmlnL2luY2x1
ZGUvbGludXgvbmZzX2ZzLmgJMjAwOC0wMS0yNCAyMzo1ODozNy4wMDAwMDAw
MDAgKzAxMDAKKysrIGxpbnV4LTIuNi4yNC1uZnNfcmEvaW5jbHVkZS9saW51
eC9uZnNfZnMuaAkyMDA4LTA0LTE0IDE1OjU4OjU3LjAwMDAwMDAwMCArMDIw
MApAQCAtNDE1LDYgKzQxNSwxMSBAQAogZXh0ZXJuIHZvaWQgbmZzX3dyaXRl
ZGF0YV9yZWxlYXNlKHZvaWQgKik7CiAKIC8qCisgKiBsaW51eC9mcy9uZnMv
Y2xpZW50LmMKKyovCitleHRlcm4gdW5zaWduZWQgaW50IG5mc19yYV9mYWN0
b3I7CisKKy8qCiAgKiBUcnkgdG8gd3JpdGUgYmFjayBldmVyeXRoaW5nIHN5
bmNocm9ub3VzbHkgKGJ1dCBjaGVjayB0aGUKICAqIHJldHVybiB2YWx1ZSEp
CiAgKi8K

--0-2033192147-1208266777=:58176--
