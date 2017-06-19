Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:37594 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbdFSSAm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Jun 2017 14:00:42 -0400
Received: by mail-it0-f49.google.com with SMTP id m47so326103iti.0
        for <linux-nfs@vger.kernel.org>; Mon, 19 Jun 2017 11:00:42 -0700 (PDT)
Subject: [PATCH v3] sunrpc: Disable splice for krb5i
From: Chuck Lever <chuck.lever@oracle.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Mon, 19 Jun 2017 14:00:40 -0400
Message-ID: <20170619175811.3673.25679.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Running a multi-threaded 8KB fio test (70/30 mix), three or four out
of twelve of the jobs fail when using krb5i. The failure is an EIO
on a read.

Troubleshooting confirmed the EIO results when the client fails to
verify the MIC of an NFS READ reply. Bruce suggested the problem
could be due to the data payload changing between the time the
reply's MIC was computed on the server and the time the reply was
actually sent.

krb5p gets around this problem by disabling RQ_SPLICE_OK. Use the
same mechanism for krb5i RPCs.

"iozone -i0 -i1 -s128m -y1k -az -I", export is tmpfs, mount is
sec=krb5i,vers=3,proto=rdma. The important numbers are the
read / reread column.

Here's without the RQ_SPLICE_OK patch:

              kB  reclen    write  rewrite    read    reread
          131072       1     7546     7929     8396     8267
          131072       2    14375    14600    15843    15639
          131072       4    19280    19248    21303    21410
          131072       8    32350    31772    35199    34883
          131072      16    36748    37477    49365    51706
          131072      32    55669    56059    57475    57389
          131072      64    74599    75190    74903    75550
          131072     128    99810   101446   102828   102724
          131072     256   122042   122612   124806   125026
          131072     512   137614   138004   141412   141267
          131072    1024   146601   148774   151356   151409
          131072    2048   180684   181727   293140   292840
          131072    4096   206907   207658   552964   549029
          131072    8192   223982   224360   454493   473469
          131072   16384   228927   228390   654734   632607

And here's with it:

              kB  reclen    write  rewrite    read    reread
          131072       1     7700     7365     7958     8011
          131072       2    13211    13303    14937    14414
          131072       4    19001    19265    20544    20657
          131072       8    30883    31097    34255    33566
          131072      16    36868    34908    51499    49944
          131072      32    56428    55535    58710    56952
          131072      64    73507    74676    75619    74378
          131072     128   100324   101442   103276   102736
          131072     256   122517   122995   124639   124150
          131072     512   137317   139007   140530   140830
          131072    1024   146807   148923   151246   151072
          131072    2048   179656   180732   292631   292034
          131072    4096   206216   208583   543355   541951
          131072    8192   223738   224273   494201   489372
          131072   16384   229313   229840   691719   668427

I would say that there is not much difference in this test.

For good measure, here's the same test with sec=krb5p:

              kB  reclen    write  rewrite    read    reread
          131072       1     5982     5881     6137     6218
          131072       2    10216    10252    10850    10932
          131072       4    12236    12575    15375    15526
          131072       8    15461    15462    23821    22351
          131072      16    25677    25811    27529    27640
          131072      32    31903    32354    34063    33857
          131072      64    42989    43188    45635    45561
          131072     128    52848    53210    56144    56141
          131072     256    59123    59214    62691    62933
          131072     512    63140    63277    66887    67025
          131072    1024    65255    65299    69213    69140
          131072    2048    76454    76555   133767   133862
          131072    4096    84726    84883   251925   250702
          131072    8192    89491    89482   270821   276085
          131072   16384    91572    91597   361768   336868

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=307
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Jeff Layton <jlayton@redhat.com>
---
Changes since v2:
- Improve patch description
- Fixed comment in svc_process_common
- Added a comment explaining why RQ_SPLICE_OK is disabled
- Add Jeff's Reviewed-by

 net/sunrpc/auth_gss/svcauth_gss.c |    8 ++++++++
 net/sunrpc/svc.c                  |    2 +-
 2 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index a54a7a3..7b1ee5a 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -838,6 +838,14 @@ u32 svcauth_gss_flavor(struct auth_domain *dom)
 	struct xdr_netobj mic;
 	struct xdr_buf integ_buf;
 
+	/* NFS READ normally uses splice to send data in-place. However
+	 * the data in cache can change after the reply's MIC is computed
+	 * but before the RPC reply is sent. To prevent the client from
+	 * rejecting the server-computed MIC in this somewhat rare case,
+	 * do not use splice with the GSS integrity service.
+	 */
+	clear_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
+
 	/* Did we already verify the signature on the original pass through? */
 	if (rqstp->rq_deferred)
 		return 0;
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index bc0f5a0..3dd8e86 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1166,7 +1166,7 @@ static __printf(2,3) void svc_printk(struct svc_rqst *rqstp, const char *fmt, ..
 	if (argv->iov_len < 6*4)
 		goto err_short_len;
 
-	/* Will be turned off only in gss privacy case: */
+	/* Will be turned off by GSS integrity and privacy services */
 	set_bit(RQ_SPLICE_OK, &rqstp->rq_flags);
 	/* Will be turned off only when NFSv4 Sessions are used */
 	set_bit(RQ_USEDEFERRAL, &rqstp->rq_flags);

