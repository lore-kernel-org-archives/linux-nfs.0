From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 1/3] Fix handling of explicit uuid
Date: Mon, 18 Aug 2008 13:17:30 +0100
Message-ID: <1219061850.3184.378.camel@pmac.infradead.org>
References: <48A5449F.7050205@nokia.com>
	 <1218808776.3184.89.camel@pmac.infradead.org>
	 <1218809892.7037.3.camel@localhost>
	 <1219058258.3184.358.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Artem.Bityutskiy@nokia.com, linux-fsdevel@vger.kernel.org,
	steved@redhat.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1219058258.3184.358.camel@pmac.infradead.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix a couple of bugs which show up if you try to explicitly set a
16-byte UUID when exporting a file system. First, exportfs cuts the
first two bytes off the UUID and writes something invalid to etab.
Second, mountd writes the _ascii_ form of the UUID to the kernel,
instead of converting it to hex.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 support/nfs/exports.c |    2 +-
 utils/mountd/cache.c  |    4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 525e5b1..334c08e 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -595,7 +595,7 @@ bad_option:
 				if (opt[5]!='\0' && *oe == '\0') 
 					ep->e_flags |= NFSEXP_FSID;
 				else if (valid_uuid(opt+5))
-					ep->e_uuid = strdup(opt+7);
+					ep->e_uuid = strdup(opt+5);
 				else {
 					xlog(L_ERROR, "%s: %d: bad fsid \"%s\"\n",
 					     flname, flline, opt);	
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index f555dcc..cd377ce 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -590,8 +590,10 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
  				qword_printhex(f, u, 16);
  			}
  		} else {
+			char u[16];
+			get_uuid(NULL, exp->e_uuid, 16, u);
  			qword_print(f, "uuid");
- 			qword_printhex(f, exp->e_uuid, 16);
+ 			qword_printhex(f, u, 16);
  		}
 #endif
 	}
-- 
1.5.5.1


-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



