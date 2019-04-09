Return-Path: <SRS0=QgGt=SL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5F86C10F0E
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 09:26:15 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5C97A20833
	for <linux-nfs@archiver.kernel.org>; Tue,  9 Apr 2019 09:26:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=spinetix.com header.i=@spinetix.com header.b="uYumGMJZ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726091AbfDIJ0O (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 9 Apr 2019 05:26:14 -0400
Received: from mail-eopbgr10056.outbound.protection.outlook.com ([40.107.1.56]:26272
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726387AbfDIJ0O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 Apr 2019 05:26:14 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=spinetix.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=20tXrmj6GEsgJRDBFeg+uqazEAnEQ7U4j6aqT0xFC40=;
 b=uYumGMJZbLfBnLPyXVPYL40jMtWbOOaLbETgTgcqhb0Hf1z3g49l4vmcTSoqLrwRqlxJ1AuoaMdEN9bVdgwiEVEIgAl7nzSOWomWPDpX1kVJWpbOysHqH+P2Cpcn1XKeg3BWHGCNsHXmYstdA34YkrA01ObpWjLRcrEoboht/24=
Received: from VI1PR01MB5167.eurprd01.prod.exchangelabs.com (20.178.120.225)
 by VI1PR01MB4733.eurprd01.prod.exchangelabs.com (20.178.11.83) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1771.19; Tue, 9 Apr 2019 09:26:08 +0000
Received: from VI1PR01MB5167.eurprd01.prod.exchangelabs.com
 ([fe80::d15f:49aa:fe02:511c]) by VI1PR01MB5167.eurprd01.prod.exchangelabs.com
 ([fe80::d15f:49aa:fe02:511c%4]) with mapi id 15.20.1771.021; Tue, 9 Apr 2019
 09:26:08 +0000
From:   Diego Santa Cruz <Diego.SantaCruz@spinetix.com>
To:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Write access check not correct on world writable directories
 (regression)
Thread-Topic: Write access check not correct on world writable directories
 (regression)
Thread-Index: AdTurF3PJLe1IvUXS+qxCgYbn/IAGg==
Date:   Tue, 9 Apr 2019 09:26:08 +0000
Message-ID: <VI1PR01MB5167A74BA4409EE4C27B592F882D0@VI1PR01MB5167.eurprd01.prod.exchangelabs.com>
Accept-Language: en-GB, fr-CH, fr-FR, en-US
Content-Language: en-US
X-MS-Has-Attach: yes
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=Diego.SantaCruz@spinetix.com; 
x-originating-ip: [46.14.255.78]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e018573e-b8f5-4c69-a760-08d6bccd65e7
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600139)(711020)(4605104)(2017052603328)(49563074)(7193020);SRVR:VI1PR01MB4733;
x-ms-traffictypediagnostic: VI1PR01MB4733:
x-microsoft-antispam-prvs: <VI1PR01MB4733DC0DD70D8155F7ED6EDD882D0@VI1PR01MB4733.eurprd01.prod.exchangelabs.com>
x-forefront-prvs: 000227DA0C
x-forefront-antispam-report: SFV:NSPM;SFS:(10009020)(376002)(396003)(346002)(136003)(39840400004)(366004)(199004)(189003)(4326008)(316002)(186003)(52536014)(476003)(7696005)(8936002)(2906002)(97736004)(486006)(99936001)(110136005)(305945005)(99286004)(74316002)(55016002)(26005)(5660300002)(53936002)(66066001)(7736002)(14444005)(5024004)(256004)(8676002)(81156014)(81166006)(9686003)(68736007)(106356001)(71190400001)(3846002)(6436002)(105586002)(72206003)(86362001)(508600001)(25786009)(6506007)(102836004)(71200400001)(33656002)(14454004)(6116002);DIR:OUT;SFP:1101;SCL:1;SRVR:VI1PR01MB4733;H:VI1PR01MB5167.eurprd01.prod.exchangelabs.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: spinetix.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: TBLN7Rh+aAQbzTdEaTfGLbtIHbpkVGdfyaKg43ydqEyBknDyCI50e5D33vepfmXLFfOJQkmd+vOoTp5rKXMJQhr/OW/92P3C82l34fgtdYCeMmzje+tjHG8Z9P7NFM//lN5k6HrbL1Lb8ddRO3g/V0yLYvdGZ2PjneLZwWpkr8s8lj+CciOs+u7mogAUrMOHtV70S8/eu8fPfvnt3clD3rfPyDc3eXap2E3n8oTROCNIU94Hp+yU7CoU+XR8DN+KLmUur4qs9S5Kg+0VWCCxHzFBcI4j4IeUGX/Mdr+e0ZHrC+TAsjGN4nLrSHH7g68cM741+oTGY8beyRCZZwuJ0AWmE7VSdnO5XulprjhXvdzP3N6aID6hHoNMyZWhrYa+1uMHHjdcZnp8ku1tmDnBbyK7HN7oe6u2cNnBGXtXoFg=
Content-Type: multipart/mixed;
        boundary="_002_VI1PR01MB5167A74BA4409EE4C27B592F882D0VI1PR01MB5167eurp_"
MIME-Version: 1.0
X-OriginatorOrg: spinetix.com
X-MS-Exchange-CrossTenant-Network-Message-Id: e018573e-b8f5-4c69-a760-08d6bccd65e7
X-MS-Exchange-CrossTenant-originalarrivaltime: 09 Apr 2019 09:26:08.2351
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 5f4034fa-ed2d-4840-a93f-acb1e9633b93
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: VI1PR01MB4733
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

--_002_VI1PR01MB5167A74BA4409EE4C27B592F882D0VI1PR01MB5167eurp_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello,

I have encountered a problem with access(dir, W_OK) calls and world writabl=
e directories on NFS which are not owner by the calling user. The call retu=
rns EACCES, even though the user can create files in the directory. I use N=
FSv3, but this may also impact other NFS versions.

Test case, on an NFSv3 mounted directory is:
1. Create world writable directory as root: sudo mkdir -m 777 testdir
2. Test that normal user can create a file: rm -f testdir/foo && touch test=
dir/foo
3. Test for writability with access: strace -o log test -w testdir && echo =
PASS || echo FAIL
4. Checking the strace log shows that access("testdir", W_OK) fails with EA=
CCES

I am using the linux-intel kernel 4.19.13, but I traced this to commit ecbb=
903c56745 in linux master (NFS: Be more careful about mapping file permissi=
ons), that went into kernel 4.13. The test works fine in earlier kernels. T=
he problem does not always show up on directories owned by the calling user=
, but it may be due to attribute caching or similar.

I am not very NFS savvy but as far as I understand the commit above changed=
 the tests in nfs_access_calc_mask() from "any bit in mask is set" to "all =
bits in mask are set". The mask for writable directories is ACCESS_MODIFY, =
ACCESS_EXTEND, ACCESS_DELETE but from what I see in a network capture the r=
esponse from the NFS server is lacking the ACCESS_DELETE bit.

The attached patch reverts the tests in nfs_access_calc_mask() to "any bit =
in mask is set", which makes the test case work again, but I am not sure it=
 is entirely correct to change all the tests, or if it would be more approp=
riate to drop ACCESS_DELETE from the NFS_DIR_MAY_WRITE mask. The patch appl=
ies cleanly on current linux master.

I checked the NFSv3 and NFSv4 RFCs, but it is not clear to me if ACCESS_DEL=
ETE is for the directory itself or its children. In any case my NFS server =
is omitting ACCESS_DELETE from the response (it is a Synology running Linux=
 kernel 3.10.105).

Sincerely,

Diego

--
Diego Santa Cruz, PhD
Technology Architect
T +41 21 341 15 50
diego.santacruz@spinetix.com
spinetix.com



--_002_VI1PR01MB5167A74BA4409EE4C27B592F882D0VI1PR01MB5167eurp_
Content-Type: application/octet-stream;
	name="0001-NFS-fix-regression-introduced-in-ecbb903c567.patch"
Content-Description: 0001-NFS-fix-regression-introduced-in-ecbb903c567.patch
Content-Disposition: attachment;
	filename="0001-NFS-fix-regression-introduced-in-ecbb903c567.patch";
	size=1863; creation-date="Tue, 09 Apr 2019 07:13:53 GMT";
	modification-date="Tue, 09 Apr 2019 07:13:53 GMT"
Content-Transfer-Encoding: base64

RnJvbSBmMTgxZTQ4MGUzYjc5YWYxZTY0YTk1OWQyOGVjYTgwMzg3MjA1NGRjIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBEaWVnbyBTYW50YSBDcnV6IDxEaWVnby5TYW50YUNydXpAc3Bp
bmV0aXguY29tPgpEYXRlOiBUdWUsIDkgQXByIDIwMTkgMDc6MDI6NDEgKzAwMDAKU3ViamVjdDog
W1BBVENIXSBORlM6IGZpeCByZWdyZXNzaW9uIGludHJvZHVjZWQgaW4gZWNiYjkwM2M1NjcKCkNv
bW1pdCBlY2JiOTAzYzU2NyAoTkZTOiBCZSBtb3JlIGNhcmVmdWwgYWJvdXQgbWFwcGluZyBmaWxl
IHBlcm1pc3Npb25zKQpicmVha3MgdGhlIGFjY2VzcyhkaXIsIFdfT0spIHRlc3Qgb24gd29ybGQg
d3JpdGFibGUgZGlyZWN0b3JpZXMgd2hvc2UKb3duZXIgaXMgbm90IHRoZSBjYWxsaW5nIHVzZXIs
IGF0IGxlYXN0IG9uIE5GU3YzLgoKQmVmb3JlIHRoYXQgY29tbWl0IGlmIGFueSBvZiB0aGUgQUND
RVNTX01PRElGWSwgQUNDRVNTX0VYVEVORCBvcgpBQ0NFU1NfREVMRVRFIGJpdHMgd2FzIHNldCB0
aGUgZGlyZWN0b3J5IHdhcyBjb25zaWRlcmVkIHdyaXRhYmxlLCBidXQKdGhhdCBjb21taXQgY2hh
bmdlZCBpdCB0byBiZSB0aGF0IGFsbCB0aG9zZSBiaXRzIG11c3QgYmUgc2V0LgpTaW1pbGFybHkg
Zm9yIGZpbGVzLCBwcmV2aW91c2x5IGFueSBvZiB0aGUgQUNDRVNTX01PRElGWSBhbmQgQUNDRVNT
X0VYVEVORApiaXRzIHdhcyBlbm91Z2gsIGJ1dCBub3cgYm90aCBvZiB0aGVtIGlzIHJlcXVpcmVk
LgoKVGhpcyBjaGFuZ2VzIHRoZSBkaXJlY3RvcnkgYW5kIGZpbGUgd3JpdGUgdGVzdHMgYmFjayB0
byBjaGVjayB0aGF0IGFueSBvZgp0aGUgYml0cyBpcyBzZXQuCgpTaWduZWQtb2ZmLWJ5OiBEaWVn
byBTYW50YSBDcnV6IDxEaWVnby5TYW50YUNydXpAc3BpbmV0aXguY29tPgotLS0KIGZzL25mcy9k
aXIuYyB8IDggKysrKy0tLS0KIDEgZmlsZSBjaGFuZ2VkLCA0IGluc2VydGlvbnMoKyksIDQgZGVs
ZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvZnMvbmZzL2Rpci5jIGIvZnMvbmZzL2Rpci5jCmluZGV4
IDhiZmFhNjU4YjJjMS4uNWQ4N2Q3OGMyZjA2IDEwMDY0NAotLS0gYS9mcy9uZnMvZGlyLmMKKysr
IGIvZnMvbmZzL2Rpci5jCkBAIC0yNDEwLDE0ICsyNDEwLDE0IEBAIG5mc19hY2Nlc3NfY2FsY19t
YXNrKHUzMiBhY2Nlc3NfcmVzdWx0LCB1bW9kZV90IHVtb2RlKQogCWlmIChhY2Nlc3NfcmVzdWx0
ICYgTkZTX01BWV9SRUFEKQogCQltYXNrIHw9IE1BWV9SRUFEOwogCWlmIChTX0lTRElSKHVtb2Rl
KSkgewotCQlpZiAoKGFjY2Vzc19yZXN1bHQgJiBORlNfRElSX01BWV9XUklURSkgPT0gTkZTX0RJ
Ul9NQVlfV1JJVEUpCisJCWlmIChhY2Nlc3NfcmVzdWx0ICYgTkZTX0RJUl9NQVlfV1JJVEUpCiAJ
CQltYXNrIHw9IE1BWV9XUklURTsKLQkJaWYgKChhY2Nlc3NfcmVzdWx0ICYgTkZTX01BWV9MT09L
VVApID09IE5GU19NQVlfTE9PS1VQKQorCQlpZiAoYWNjZXNzX3Jlc3VsdCAmIE5GU19NQVlfTE9P
S1VQKQogCQkJbWFzayB8PSBNQVlfRVhFQzsKIAl9IGVsc2UgaWYgKFNfSVNSRUcodW1vZGUpKSB7
Ci0JCWlmICgoYWNjZXNzX3Jlc3VsdCAmIE5GU19GSUxFX01BWV9XUklURSkgPT0gTkZTX0ZJTEVf
TUFZX1dSSVRFKQorCQlpZiAoYWNjZXNzX3Jlc3VsdCAmIE5GU19GSUxFX01BWV9XUklURSkKIAkJ
CW1hc2sgfD0gTUFZX1dSSVRFOwotCQlpZiAoKGFjY2Vzc19yZXN1bHQgJiBORlNfTUFZX0VYRUNV
VEUpID09IE5GU19NQVlfRVhFQ1VURSkKKwkJaWYgKGFjY2Vzc19yZXN1bHQgJiBORlNfTUFZX0VY
RUNVVEUpCiAJCQltYXNrIHw9IE1BWV9FWEVDOwogCX0gZWxzZSBpZiAoYWNjZXNzX3Jlc3VsdCAm
IE5GU19NQVlfV1JJVEUpCiAJCQltYXNrIHw9IE1BWV9XUklURTsK

--_002_VI1PR01MB5167A74BA4409EE4C27B592F882D0VI1PR01MB5167eurp_--
