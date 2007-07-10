From: NeilBrown <neilb@suse.de>
Subject: [PATCH 016 of 20] knfsd: rpc: add gss krb5 and spkm3 oid
	values
Date: Tue, 10 Jul 2007 12:27:55 +1000
Message-ID: <1070710022755.13554@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net,
	Usha Ketineni <uketinen@us.ibm.com>,
	Usha Ketineni <ketineni@us.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85SI-00057k-6z
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:27:58 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85SL-0004iP-AJ
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:28:01 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: Usha Ketineni <ketineni@us.ibm.com>

Adds oid values to the gss_api mechanism structures.  On the NFSV4
server side, these are required as part of the security triple
(oid,qop,service) information being sent in the response of the SECINFO
operation.

Signed-off-by: Usha Ketineni <uketinen@us.ibm.com>
Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/gss_krb5_mech.c  |    1 +
 ./net/sunrpc/auth_gss/gss_spkm3_mech.c |    1 +
 2 files changed, 2 insertions(+)

diff .prev/net/sunrpc/auth_gss/gss_krb5_mech.c ./net/sunrpc/auth_gss/gss_krb5_mech.c
--- .prev/net/sunrpc/auth_gss/gss_krb5_mech.c	2007-07-10 11:19:53.000000000 +1000
+++ ./net/sunrpc/auth_gss/gss_krb5_mech.c	2007-07-10 11:51:00.000000000 +1000
@@ -231,6 +231,7 @@ static struct pf_desc gss_kerberos_pfs[]
 static struct gss_api_mech gss_kerberos_mech = {
 	.gm_name	= "krb5",
 	.gm_owner	= THIS_MODULE,
+	.gm_oid		= {9, (void *)"\x2a\x86\x48\x86\xf7\x12\x01\x02\x02"},
 	.gm_ops		= &gss_kerberos_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_kerberos_pfs),
 	.gm_pfs		= gss_kerberos_pfs,

diff .prev/net/sunrpc/auth_gss/gss_spkm3_mech.c ./net/sunrpc/auth_gss/gss_spkm3_mech.c
--- .prev/net/sunrpc/auth_gss/gss_spkm3_mech.c	2007-07-10 11:19:53.000000000 +1000
+++ ./net/sunrpc/auth_gss/gss_spkm3_mech.c	2007-07-10 11:51:00.000000000 +1000
@@ -217,6 +217,7 @@ static struct pf_desc gss_spkm3_pfs[] = 
 static struct gss_api_mech gss_spkm3_mech = {
 	.gm_name	= "spkm3",
 	.gm_owner	= THIS_MODULE,
+	.gm_oid		= {7, "\053\006\001\005\005\001\003"},
 	.gm_ops		= &gss_spkm3_ops,
 	.gm_pf_num	= ARRAY_SIZE(gss_spkm3_pfs),
 	.gm_pfs		= gss_spkm3_pfs,

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
