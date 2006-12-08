From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 18] knfsd: svcrpc: fix gss krb5i memory leak
Date: Fri, 8 Dec 2006 12:13:31 +1100
Message-ID: <1061208011331.30579@suse.de>
References: <20061208120939.30428.patches@notabene>
Content-Type: multipart/mixed; boundary="===============0564985576=="
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUIg-000373-EO
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:18 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUIh-000127-AY
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:13:19 -0800
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0564985576==


From: J.Bruce Fields <bfields@fieldses.org>

The memory leak here is embarassingly obvious.

This fixes a problem that causes the kernel to leak a small amount of
memory every time it receives a integrity-protected request.

Thanks to Aimé Le Rouzic for the bug report.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff .prev/net/sunrpc/auth_gss/svcauth_gss.c ./net/sunrpc/auth_gss/svcauth_gss.c
--- .prev/net/sunrpc/auth_gss/svcauth_gss.c	2006-12-08 12:07:28.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-12-08 12:08:05.000000000 +1100
@@ -818,19 +818,19 @@ unwrap_integ_data(struct xdr_buf *buf, u
 
 	integ_len = svc_getnl(&buf->head[0]);
 	if (integ_len & 3)
-		goto out;
+		return stat;
 	if (integ_len > buf->len)
-		goto out;
+		return stat;
 	if (xdr_buf_subsegment(buf, &integ_buf, 0, integ_len))
 		BUG();
 	/* copy out mic... */
 	if (read_u32_from_xdr_buf(buf, integ_len, &mic.len))
 		BUG();
 	if (mic.len > RPC_MAX_AUTH_SIZE)
-		goto out;
+		return stat;
 	mic.data = kmalloc(mic.len, GFP_KERNEL);
 	if (!mic.data)
-		goto out;
+		return stat;
 	if (read_bytes_from_xdr_buf(buf, integ_len + 4, mic.data, mic.len))
 		goto out;
 	maj_stat = gss_verify_mic(ctx, &integ_buf, &mic);
@@ -840,6 +840,7 @@ unwrap_integ_data(struct xdr_buf *buf, u
 		goto out;
 	stat = 0;
 out:
+	kfree(mic.data);
 	return stat;
 }
 


--===============0564985576==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0564985576==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0564985576==--
