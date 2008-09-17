From: Martin Knoblauch <knobi@knobisoft.de>
Subject: [RFC][Resend] Make NFS-Client readahead tunable
Date: Wed, 17 Sep 2008 06:06:40 -0700 (PDT)
Message-ID: <997439.5560.qm@web32601.mail.mud.yahoo.com>
Reply-To: Martin Knoblauch <knobi@knobisoft.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0-916351980-1221656800=:5560"
Cc: linux-kernel@vger.kernel.org
To: linux-nfs list <linux-nfs@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753976AbYIQNGw@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--0-916351980-1221656800=:5560
Content-Type: text/plain; charset=us-ascii

Hi,

the following/attached patch works around a [obscure] problem when an 2.6 (not sure/caring about 2.4) NFS client accesses an "offline" file on a Sun/Solaris-10 NFS server when the underlying filesystem is of type SAM-FS. Happens with RHEL4/5 and mainline kernels. Frankly, it is not a Linux problem, but the chance for a short-/mid-term solution from Sun are very slim. So, being lazy, I would love to get this patch into Linux. If not, I just will have to maintain it for eternity out of tree.

The problem: SAM-FS is Suns proprietary HSM filesystem. It stores meta-data and a relatively small amount of data "online" on disk and pushes old or infrequently used data to "offline" media like e.g. tape. This is completely transparent to the users. If the date for an "offline" file is needed, the so called "stager daemon" copies it back from the offline medium. All of this works great most of the time. Now, if an Linux NFS client tries to read such an offline file, performance drops to "extremely slow". After lengthly investigation of tcp-dumps, mount options and procedures involving black cats at midnight, we found out that the readahead behaviour of the Linux NFS client causes the problem. Basically it seems to issue read requests up to 15*rsize to the server. In the case of the "offl
 ine" files, this behaviour causes heavy competition for the inode lock between the NFSD process and the stager daemon on the Solaris server.

- The real solution: fixing SAM-FS/NFSD interaction. Sun engineering acks the problem, but a solution will need time. Lots of it.
- The working solution: disable the client side readahead, or make it tunable. The patch does that by introducing a NFS module parameter "ra_factor" which can take values between 1 and 15 (default 15) and a tunable "/proc/sys/fs/nfs/nfs_ra_factor" with the same range and default.

Signed-off-by: Martin Knoblauch <knobi@knobisoft.de>

diff -urp linux-2.6.27-rc6-git4/fs/nfs/client.c linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/client.c
--- linux-2.6.27-rc6-git4/fs/nfs/client.c       2008-09-17 11:35:21.000000000 +0200
+++ linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/client.c        2008-09-17 11:55:18.000000000 +0200
@@ -722,6 +722,11 @@ error:
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
@@ -746,7 +751,11 @@ static void nfs_server_set_fsinfo(struct
                server->rsize = NFS_MAX_FILE_IO_SIZE;
        server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;

-       server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
+       dprintk("nfs_server_set_fsinfo: rsize, wsize, rpages, \
+               nfs_ra_factor, ra_pages: %d %d %d %d %d\n",
+               server->rsize,server->wsize,server->rpages,
+               nfs_ra_factor,server->rpages * nfs_ra_factor);
+       server->backing_dev_info.ra_pages = server->rpages * nfs_ra_factor;

        if (server->wsize > max_rpc_payload)
                server->wsize = max_rpc_payload;
diff -urp linux-2.6.27-rc6-git4/fs/nfs/inode.c linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/inode.c
--- linux-2.6.27-rc6-git4/fs/nfs/inode.c        2008-09-17 11:35:21.000000000 +0200
+++ linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/inode.c 2008-09-17 11:45:09.000000000 +0200
@@ -53,6 +53,8 @@

 /* Default is to see 64-bit inode numbers */
 static int enable_ino64 = NFS_64_BIT_INODE_NUMBERS_ENABLED;
+static unsigned int ra_factor __read_mostly = NFS_MAX_READAHEAD;
+

 static void nfs_invalidate_inode(struct inode *);
 static int nfs_update_inode(struct inode *, struct nfs_fattr *);
@@ -1347,6 +1349,12 @@ static int __init init_nfs_fs(void)
 #endif
        if ((err = register_nfs_fs()) != 0)
                goto out;
+
+       if (ra_factor < 1 || ra_factor > NFS_MAX_READAHEAD)
+               nfs_ra_factor = NFS_MAX_READAHEAD;
+       else
+               nfs_ra_factor = ra_factor;
+
        return 0;
 out:
 #ifdef CONFIG_PROC_FS
@@ -1388,6 +1396,10 @@ static void __exit exit_nfs_fs(void)
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_LICENSE("GPL");
 module_param(enable_ino64, bool, 0644);
+MODULE_PARM_DESC(enable_ino64, "Enable 64-bit inode numbers (Default: 1)");
+module_param(ra_factor, uint, 0644);
+MODULE_PARM_DESC(ra_factor,
+       "Number of rsize read-ahead requests (Default/Max: 15, Min: 1)");

 module_init(init_nfs_fs)
 module_exit(exit_nfs_fs)
diff -urp linux-2.6.27-rc6-git4/fs/nfs/sysctl.c linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/sysctl.c
--- linux-2.6.27-rc6-git4/fs/nfs/sysctl.c       2008-07-13 23:51:29.000000000 +0200
+++ linux-2.6.27-rc6-git4-nfs_ra/fs/nfs/sysctl.c        2008-09-17 11:45:09.000000000 +0200
@@ -14,9 +14,12 @@
 #include <linux/nfs_fs.h>

 #include "callback.h"
+#include "internal.h"

 static const int nfs_set_port_min = 0;
 static const int nfs_set_port_max = 65535;
+static const unsigned int min_nfs_ra_factor = 1;
+static const unsigned int max_nfs_ra_factor = NFS_MAX_READAHEAD;
 static struct ctl_table_header *nfs_callback_sysctl_table;

 static ctl_table nfs_cb_sysctls[] = {
@@ -58,6 +61,16 @@ static ctl_table nfs_cb_sysctls[] = {
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

diff -urp linux-2.6.27-rc6-git4/include/linux/nfs_fs.h linux-2.6.27-rc6-git4-nfs_ra/include/linux/nfs_fs.h
--- linux-2.6.27-rc6-git4/include/linux/nfs_fs.h        2008-09-17 11:35:25.000000000 +0200
+++ linux-2.6.27-rc6-git4-nfs_ra/include/linux/nfs_fs.h 2008-09-17 11:45:09.000000000 +0200
@@ -464,6 +464,11 @@ extern int nfs_writeback_done(struct rpc
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
diff -urp linux-2.6.27-rc6-git4/Makefile linux-2.6.27-rc6-git4-nfs_ra/Makefile
--- linux-2.6.27-rc6-git4/Makefile      2008-09-17 11:35:56.000000000 +0200
+++ linux-2.6.27-rc6-git4-nfs_ra/Makefile       2008-09-17 11:45:09.000000000 +0200
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 6
 SUBLEVEL = 27
-EXTRAVERSION = -rc6-git4
+EXTRAVERSION = -rc6-git4-nfs_ra
 NAME = Rotary Wombat

 # *DOCUMENTATION*



Cheers
Martin

------------------------------------------------------
Martin Knoblauch
email: k n o b i AT knobisoft DOT de
www:  http://www.knobisoft.de
--0-916351980-1221656800=:5560
Content-Type: text/x-patch; name="nfs_ra-2.6.27-rc6-git4.diff"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="nfs_ra-2.6.27-rc6-git4.diff"

ZGlmZiAtdXJwIGxpbnV4LTIuNi4yNy1yYzYtZ2l0NC9mcy9uZnMvY2xpZW50
LmMgbGludXgtMi42LjI3LXJjNi1naXQ0LW5mc19yYS9mcy9uZnMvY2xpZW50
LmMKLS0tIGxpbnV4LTIuNi4yNy1yYzYtZ2l0NC9mcy9uZnMvY2xpZW50LmMJ
MjAwOC0wOS0xNyAxMTozNToyMS4wMDAwMDAwMDAgKzAyMDAKKysrIGxpbnV4
LTIuNi4yNy1yYzYtZ2l0NC1uZnNfcmEvZnMvbmZzL2NsaWVudC5jCTIwMDgt
MDktMTcgMTE6NTU6MTguMDAwMDAwMDAwICswMjAwCkBAIC03MjIsNiArNzIy
LDExIEBAIGVycm9yOgogfQogCiAvKgorICogTkZTIENsaWVudCBSZWFkLUFo
ZWFkIGZhY3RvcgorKi8KK3Vuc2lnbmVkIGludCBuZnNfcmFfZmFjdG9yOwor
CisvKgogICogTG9hZCB1cCB0aGUgc2VydmVyIHJlY29yZCBmcm9tIGluZm9y
bWF0aW9uIGdhaW5lZCBpbiBhbiBmc2luZm8gcmVjb3JkCiAgKi8KIHN0YXRp
YyB2b2lkIG5mc19zZXJ2ZXJfc2V0X2ZzaW5mbyhzdHJ1Y3QgbmZzX3NlcnZl
ciAqc2VydmVyLCBzdHJ1Y3QgbmZzX2ZzaW5mbyAqZnNpbmZvKQpAQCAtNzQ2
LDcgKzc1MSwxMSBAQCBzdGF0aWMgdm9pZCBuZnNfc2VydmVyX3NldF9mc2lu
Zm8oc3RydWN0CiAJCXNlcnZlci0+cnNpemUgPSBORlNfTUFYX0ZJTEVfSU9f
U0laRTsKIAlzZXJ2ZXItPnJwYWdlcyA9IChzZXJ2ZXItPnJzaXplICsgUEFH
RV9DQUNIRV9TSVpFIC0gMSkgPj4gUEFHRV9DQUNIRV9TSElGVDsKIAotCXNl
cnZlci0+YmFja2luZ19kZXZfaW5mby5yYV9wYWdlcyA9IHNlcnZlci0+cnBh
Z2VzICogTkZTX01BWF9SRUFEQUhFQUQ7CisJZHByaW50aygibmZzX3NlcnZl
cl9zZXRfZnNpbmZvOiByc2l6ZSwgd3NpemUsIHJwYWdlcywgXAorCQluZnNf
cmFfZmFjdG9yLCByYV9wYWdlczogJWQgJWQgJWQgJWQgJWRcbiIsCisJCXNl
cnZlci0+cnNpemUsc2VydmVyLT53c2l6ZSxzZXJ2ZXItPnJwYWdlcywKKwkJ
bmZzX3JhX2ZhY3RvcixzZXJ2ZXItPnJwYWdlcyAqIG5mc19yYV9mYWN0b3Ip
OworCXNlcnZlci0+YmFja2luZ19kZXZfaW5mby5yYV9wYWdlcyA9IHNlcnZl
ci0+cnBhZ2VzICogbmZzX3JhX2ZhY3RvcjsKIAogCWlmIChzZXJ2ZXItPndz
aXplID4gbWF4X3JwY19wYXlsb2FkKQogCQlzZXJ2ZXItPndzaXplID0gbWF4
X3JwY19wYXlsb2FkOwpkaWZmIC11cnAgbGludXgtMi42LjI3LXJjNi1naXQ0
L2ZzL25mcy9pbm9kZS5jIGxpbnV4LTIuNi4yNy1yYzYtZ2l0NC1uZnNfcmEv
ZnMvbmZzL2lub2RlLmMKLS0tIGxpbnV4LTIuNi4yNy1yYzYtZ2l0NC9mcy9u
ZnMvaW5vZGUuYwkyMDA4LTA5LTE3IDExOjM1OjIxLjAwMDAwMDAwMCArMDIw
MAorKysgbGludXgtMi42LjI3LXJjNi1naXQ0LW5mc19yYS9mcy9uZnMvaW5v
ZGUuYwkyMDA4LTA5LTE3IDExOjQ1OjA5LjAwMDAwMDAwMCArMDIwMApAQCAt
NTMsNiArNTMsOCBAQAogCiAvKiBEZWZhdWx0IGlzIHRvIHNlZSA2NC1iaXQg
aW5vZGUgbnVtYmVycyAqLwogc3RhdGljIGludCBlbmFibGVfaW5vNjQgPSBO
RlNfNjRfQklUX0lOT0RFX05VTUJFUlNfRU5BQkxFRDsKK3N0YXRpYyB1bnNp
Z25lZCBpbnQgcmFfZmFjdG9yIF9fcmVhZF9tb3N0bHkgPSBORlNfTUFYX1JF
QURBSEVBRDsKKwogCiBzdGF0aWMgdm9pZCBuZnNfaW52YWxpZGF0ZV9pbm9k
ZShzdHJ1Y3QgaW5vZGUgKik7CiBzdGF0aWMgaW50IG5mc191cGRhdGVfaW5v
ZGUoc3RydWN0IGlub2RlICosIHN0cnVjdCBuZnNfZmF0dHIgKik7CkBAIC0x
MzQ3LDYgKzEzNDksMTIgQEAgc3RhdGljIGludCBfX2luaXQgaW5pdF9uZnNf
ZnModm9pZCkKICNlbmRpZgogCWlmICgoZXJyID0gcmVnaXN0ZXJfbmZzX2Zz
KCkpICE9IDApCiAJCWdvdG8gb3V0OworCisJaWYgKHJhX2ZhY3RvciA8IDEg
fHwgcmFfZmFjdG9yID4gTkZTX01BWF9SRUFEQUhFQUQpCisJCW5mc19yYV9m
YWN0b3IgPSBORlNfTUFYX1JFQURBSEVBRDsKKwllbHNlCisJCW5mc19yYV9m
YWN0b3IgPSByYV9mYWN0b3I7CisKIAlyZXR1cm4gMDsKIG91dDoKICNpZmRl
ZiBDT05GSUdfUFJPQ19GUwpAQCAtMTM4OCw2ICsxMzk2LDEwIEBAIHN0YXRp
YyB2b2lkIF9fZXhpdCBleGl0X25mc19mcyh2b2lkKQogTU9EVUxFX0FVVEhP
UigiT2xhZiBLaXJjaCA8b2tpckBtb25hZC5zd2IuZGU+Iik7CiBNT0RVTEVf
TElDRU5TRSgiR1BMIik7CiBtb2R1bGVfcGFyYW0oZW5hYmxlX2lubzY0LCBi
b29sLCAwNjQ0KTsKK01PRFVMRV9QQVJNX0RFU0MoZW5hYmxlX2lubzY0LCAi
RW5hYmxlIDY0LWJpdCBpbm9kZSBudW1iZXJzIChEZWZhdWx0OiAxKSIpOwor
bW9kdWxlX3BhcmFtKHJhX2ZhY3RvciwgdWludCwgMDY0NCk7CitNT0RVTEVf
UEFSTV9ERVNDKHJhX2ZhY3RvciwKKwkiTnVtYmVyIG9mIHJzaXplIHJlYWQt
YWhlYWQgcmVxdWVzdHMgKERlZmF1bHQvTWF4OiAxNSwgTWluOiAxKSIpOwog
CiBtb2R1bGVfaW5pdChpbml0X25mc19mcykKIG1vZHVsZV9leGl0KGV4aXRf
bmZzX2ZzKQpkaWZmIC11cnAgbGludXgtMi42LjI3LXJjNi1naXQ0L2ZzL25m
cy9zeXNjdGwuYyBsaW51eC0yLjYuMjctcmM2LWdpdDQtbmZzX3JhL2ZzL25m
cy9zeXNjdGwuYwotLS0gbGludXgtMi42LjI3LXJjNi1naXQ0L2ZzL25mcy9z
eXNjdGwuYwkyMDA4LTA3LTEzIDIzOjUxOjI5LjAwMDAwMDAwMCArMDIwMAor
KysgbGludXgtMi42LjI3LXJjNi1naXQ0LW5mc19yYS9mcy9uZnMvc3lzY3Rs
LmMJMjAwOC0wOS0xNyAxMTo0NTowOS4wMDAwMDAwMDAgKzAyMDAKQEAgLTE0
LDkgKzE0LDEyIEBACiAjaW5jbHVkZSA8bGludXgvbmZzX2ZzLmg+CiAKICNp
bmNsdWRlICJjYWxsYmFjay5oIgorI2luY2x1ZGUgImludGVybmFsLmgiCiAK
IHN0YXRpYyBjb25zdCBpbnQgbmZzX3NldF9wb3J0X21pbiA9IDA7CiBzdGF0
aWMgY29uc3QgaW50IG5mc19zZXRfcG9ydF9tYXggPSA2NTUzNTsKK3N0YXRp
YyBjb25zdCB1bnNpZ25lZCBpbnQgbWluX25mc19yYV9mYWN0b3IgPSAxOwor
c3RhdGljIGNvbnN0IHVuc2lnbmVkIGludCBtYXhfbmZzX3JhX2ZhY3RvciA9
IE5GU19NQVhfUkVBREFIRUFEOwogc3RhdGljIHN0cnVjdCBjdGxfdGFibGVf
aGVhZGVyICpuZnNfY2FsbGJhY2tfc3lzY3RsX3RhYmxlOwogCiBzdGF0aWMg
Y3RsX3RhYmxlIG5mc19jYl9zeXNjdGxzW10gPSB7CkBAIC01OCw2ICs2MSwx
NiBAQCBzdGF0aWMgY3RsX3RhYmxlIG5mc19jYl9zeXNjdGxzW10gPSB7CiAJ
CS5tb2RlCQk9IDA2NDQsCiAJCS5wcm9jX2hhbmRsZXIJPSAmcHJvY19kb2lu
dHZlYywKIAl9LAorCXsKKwkJLmN0bF9uYW1lID0gQ1RMX1VOTlVNQkVSRUQs
CisJCS5wcm9jbmFtZSA9ICJuZnNfcmFfZmFjdG9yIiwKKwkJLmRhdGEgPSAm
bmZzX3JhX2ZhY3RvciwKKwkJLm1heGxlbiA9IHNpemVvZih1bnNpZ25lZCBp
bnQpLAorCQkubW9kZSA9IDA2NDQsCisJCS5wcm9jX2hhbmRsZXIgPSAmcHJv
Y19kb2ludHZlY19taW5tYXgsCisJCS5leHRyYTEgPSAodW5zaWduZWQgaW50
ICopJm1pbl9uZnNfcmFfZmFjdG9yLAorCQkuZXh0cmEyID0gKHVuc2lnbmVk
IGludCAqKSZtYXhfbmZzX3JhX2ZhY3RvciwKKwl9LAogCXsgLmN0bF9uYW1l
ID0gMCB9CiB9OwogCmRpZmYgLXVycCBsaW51eC0yLjYuMjctcmM2LWdpdDQv
aW5jbHVkZS9saW51eC9uZnNfZnMuaCBsaW51eC0yLjYuMjctcmM2LWdpdDQt
bmZzX3JhL2luY2x1ZGUvbGludXgvbmZzX2ZzLmgKLS0tIGxpbnV4LTIuNi4y
Ny1yYzYtZ2l0NC9pbmNsdWRlL2xpbnV4L25mc19mcy5oCTIwMDgtMDktMTcg
MTE6MzU6MjUuMDAwMDAwMDAwICswMjAwCisrKyBsaW51eC0yLjYuMjctcmM2
LWdpdDQtbmZzX3JhL2luY2x1ZGUvbGludXgvbmZzX2ZzLmgJMjAwOC0wOS0x
NyAxMTo0NTowOS4wMDAwMDAwMDAgKzAyMDAKQEAgLTQ2NCw2ICs0NjQsMTEg
QEAgZXh0ZXJuIGludCBuZnNfd3JpdGViYWNrX2RvbmUoc3RydWN0IHJwYwog
ZXh0ZXJuIHZvaWQgbmZzX3dyaXRlZGF0YV9yZWxlYXNlKHZvaWQgKik7CiAK
IC8qCisgKiBsaW51eC9mcy9uZnMvY2xpZW50LmMKKyovCitleHRlcm4gdW5z
aWduZWQgaW50IG5mc19yYV9mYWN0b3I7CisKKy8qCiAgKiBUcnkgdG8gd3Jp
dGUgYmFjayBldmVyeXRoaW5nIHN5bmNocm9ub3VzbHkgKGJ1dCBjaGVjayB0
aGUKICAqIHJldHVybiB2YWx1ZSEpCiAgKi8KZGlmZiAtdXJwIGxpbnV4LTIu
Ni4yNy1yYzYtZ2l0NC9NYWtlZmlsZSBsaW51eC0yLjYuMjctcmM2LWdpdDQt
bmZzX3JhL01ha2VmaWxlCi0tLSBsaW51eC0yLjYuMjctcmM2LWdpdDQvTWFr
ZWZpbGUJMjAwOC0wOS0xNyAxMTozNTo1Ni4wMDAwMDAwMDAgKzAyMDAKKysr
IGxpbnV4LTIuNi4yNy1yYzYtZ2l0NC1uZnNfcmEvTWFrZWZpbGUJMjAwOC0w
OS0xNyAxMTo0NTowOS4wMDAwMDAwMDAgKzAyMDAKQEAgLTEsNyArMSw3IEBA
CiBWRVJTSU9OID0gMgogUEFUQ0hMRVZFTCA9IDYKIFNVQkxFVkVMID0gMjcK
LUVYVFJBVkVSU0lPTiA9IC1yYzYtZ2l0NAorRVhUUkFWRVJTSU9OID0gLXJj
Ni1naXQ0LW5mc19yYQogTkFNRSA9IFJvdGFyeSBXb21iYXQKIAogIyAqRE9D
VU1FTlRBVElPTioK

--0-916351980-1221656800=:5560--
