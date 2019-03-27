Return-Path: <SRS0=BAWL=R6=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF9D2C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Mar 2019 21:25:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 81619206B8
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Mar 2019 21:25:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727416AbfC0VZD convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Mar 2019 17:25:03 -0400
Received: from mail-eopbgr670049.outbound.protection.outlook.com ([40.107.67.49]:36320
        "EHLO CAN01-TO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727210AbfC0VZD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Mar 2019 17:25:03 -0400
Received: from YT1PR01MB3546.CANPRD01.PROD.OUTLOOK.COM (10.255.43.212) by
 YT1PR01MB3420.CANPRD01.PROD.OUTLOOK.COM (10.255.43.97) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1750.15; Wed, 27 Mar 2019 21:25:01 +0000
Received: from YT1PR01MB3546.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::e9ce:7a38:abef:5660]) by YT1PR01MB3546.CANPRD01.PROD.OUTLOOK.COM
 ([fe80::e9ce:7a38:abef:5660%5]) with mapi id 15.20.1730.019; Wed, 27 Mar 2019
 21:25:01 +0000
From:   Rick Macklem <rmacklem@uoguelph.ca>
To:     Armin Zentai <armin@zentai.name>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH] Add EMFILE to nfsd errors
Thread-Topic: [PATCH] Add EMFILE to nfsd errors
Thread-Index: AQHU5NEBqrcKtYWwGUW+HjBTriQlx6Yf/UYU
Date:   Wed, 27 Mar 2019 21:25:01 +0000
Message-ID: <YT1PR01MB35469D45DD321F14EFAD0536DD580@YT1PR01MB3546.CANPRD01.PROD.OUTLOOK.COM>
References: <23B588B3-C119-4036-B60B-7872A52129F4@zentai.name>
In-Reply-To: <23B588B3-C119-4036-B60B-7872A52129F4@zentai.name>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: fe1ff3af-b602-4902-fc2b-08d6b2faabb5
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:YT1PR01MB3420;
x-ms-traffictypediagnostic: YT1PR01MB3420:
x-microsoft-antispam-prvs: <YT1PR01MB3420B2CFA401B9C8BE5CE71CDD580@YT1PR01MB3420.CANPRD01.PROD.OUTLOOK.COM>
x-forefront-prvs: 0989A7979C
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(979002)(136003)(39850400004)(376002)(346002)(396003)(366004)(189003)(199004)(786003)(316002)(478600001)(102836004)(2906002)(76176011)(14454004)(99286004)(6436002)(11346002)(52536014)(81156014)(110136005)(81166006)(446003)(71200400001)(71190400001)(7696005)(6506007)(5660300002)(53546011)(8936002)(53936002)(486006)(86362001)(105586002)(55016002)(8676002)(68736007)(6246003)(476003)(9686003)(229853002)(74482002)(25786009)(186003)(305945005)(33656002)(74316002)(106356001)(97736004)(14444005)(256004)(6346003)(26005)(2501003)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1101;SCL:1;SRVR:YT1PR01MB3420;H:YT1PR01MB3546.CANPRD01.PROD.OUTLOOK.COM;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: uoguelph.ca does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=rmacklem@uoguelph.ca; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 7LBYZL6nTQBsAGc0MFdoMGkqv4qeJXtHMs6m9/5WdRVumEdVXZSKkr3UKmVy4t7WtRprhRNQKgTuXz1u0YsrpTb7EuA2Mjk89qrcOf7n26UQtVEvpNKmWcCb8z17tsQkrboHsgYttTw/F2FcRlCX/+UndvnwHxkN2Qrjern1yw29Xoju0+cv8s7/AlKIC5jIZE2s6Kz/XNOsx/y4pmMUymlbtqM5ypumCLlD06yc+WZ21cft4kJmB0VY0sksM9uIs/iL9Q8A08CqmlDS5ZeIHfnI/N+Uh3WRehmi6p//EPp35zRXe8jx4EbEv53dRqMjYD820Sb45FhlhkBqvZhJeibhaI46PUzj/S9QGi4Thu/G+MiubfUI1i5obfqGRWLVQqo53xYgQfDvyOcEmo3Wz3oFYb4fFWVJOmfRszU1YZo=
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
MIME-Version: 1.0
X-OriginatorOrg: uoguelph.ca
X-MS-Exchange-CrossTenant-Network-Message-Id: fe1ff3af-b602-4902-fc2b-08d6b2faabb5
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Mar 2019 21:25:01.0891
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: be62a12b-2cad-49a1-a5fa-85f4f3156a7d
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: YT1PR01MB3420
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I don't believe that EMFILE is specified as an NFS error in the RFCs?

rick

________________________________________
From: linux-nfs-owner@vger.kernel.org <linux-nfs-owner@vger.kernel.org> on behalf of Armin Zentai <armin@zentai.name>
Sent: Wednesday, March 27, 2019 3:03:43 PM
To: linux-nfs@vger.kernel.org; J. Bruce Fields; Jeff Layton
Subject: [PATCH] Add EMFILE to nfsd errors

This patch adds the EMFILE to nfsd errors for better error output.

I've encountered a hard-to-debug situation, when I used a fuse under an NFS export, because of a 'too many open files' error.

Before the patch nfsd warns with this message:
'nfsd4_process_open2 failed to open newly-created file! status=5'  (5: EIO)

After the patch:
'nfsd4_process_open2 failed to open newly-created file! status=24' (24: EMFILE)

Also the client returns with EREMOTEIO instead of EIO, which indicates a server error from the NFS client side.

Signed-off-by: Armin ZENTAI <armin@zentai.name>
---
 fs/nfsd/nfsd.h           | 1 +
 fs/nfsd/nfsproc.c        | 1 +
 include/uapi/linux/nfs.h | 1 +
 3 files changed, 3 insertions(+)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 066899929863..19a269d75fb5 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -217,6 +217,7 @@ void                nfsd_lockd_shutdown(void);
 #define        nfserr_cb_path_down     cpu_to_be32(NFSERR_CB_PATH_DOWN)
 #define        nfserr_locked           cpu_to_be32(NFSERR_LOCKED)
 #define        nfserr_wrongsec         cpu_to_be32(NFSERR_WRONGSEC)
+#define nfserr_emfile                  cpu_to_be32(NFSERR_EMFILE)
 #define nfserr_badiomode               cpu_to_be32(NFS4ERR_BADIOMODE)
 #define nfserr_badlayout               cpu_to_be32(NFS4ERR_BADLAYOUT)
 #define nfserr_bad_session_digest      cpu_to_be32(NFS4ERR_BAD_SESSION_DIGEST)
diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 0d20fd161225..ff9e883c7829 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -810,6 +810,7 @@ nfserrno (int errno)
                { nfserr_serverfault, -ENFILE },
                { nfserr_io, -EUCLEAN },
                { nfserr_perm, -ENOKEY },
+               { nfserr_emfile, -EMFILE },
        };
        int     i;

diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index 946cb62d64b0..dcb0ea33f2db 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -57,6 +57,7 @@
        NFSERR_NOTDIR = 20,             /* v2 v3 v4 */
        NFSERR_ISDIR = 21,              /* v2 v3 v4 */
        NFSERR_INVAL = 22,              /* v2 v3 v4 */
+       NFSERR_EMFILE = 24,             /* v2 v3 v4 */
        NFSERR_FBIG = 27,               /* v2 v3 v4 */
        NFSERR_NOSPC = 28,              /* v2 v3 v4 */
        NFSERR_ROFS = 30,               /* v2 v3 v4 */
--
2.11.0

