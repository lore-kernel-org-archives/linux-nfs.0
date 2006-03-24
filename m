From: NeilBrown <neilb@suse.de>
Subject: [PATCH 001 of 2] knfsd: Tidy up unix_domain_find
Date: Fri, 24 Mar 2006 16:53:52 +1100
Message-ID: <1060324055352.2333@suse.de>
References: <20060324165210.2285.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932538AbWCXFz5@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


We shouldn't really compare &new->h with anything when new ==NULL,
and gather three different if statements that all start
  if (rv ...

into one large if.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2006-03-24 12:06:14.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2006-03-24 12:08:04.000000000 +1100
@@ -36,16 +36,16 @@ struct auth_domain *unix_domain_find(cha
 
 	rv = auth_domain_lookup(name, NULL);
 	while(1) {
-		if (rv != &new->h) {
-			if (new) auth_domain_put(&new->h);
+		if (rv) {
+			if (new && rv != &new->h)
+				auth_domain_put(&new->h);
+
+			if (rv->flavour != &svcauth_unix) {
+				auth_domain_put(rv);
+				return NULL;
+			}
 			return rv;
 		}
-		if (rv && rv->flavour != &svcauth_unix) {
-			auth_domain_put(rv);
-			return NULL;
-		}
-		if (rv)
-			return rv;
 
 		new = kmalloc(sizeof(*new), GFP_KERNEL);
 		if (new == NULL)
