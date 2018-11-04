Return-Path: <SRS0=jFnA=NP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6846EECDE44
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Nov 2018 13:56:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3104B204FD
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Nov 2018 13:56:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="VrImo/OE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3104B204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729339AbeKDXLs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 4 Nov 2018 18:11:48 -0500
Received: from mail-sn1nam02on0119.outbound.protection.outlook.com ([104.47.36.119]:32558
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729771AbeKDXLs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 4 Nov 2018 18:11:48 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+Mre4mUB9NqoE0LMBJEsqhahr8OoAtumP758t3QpcKU=;
 b=VrImo/OE1+NJnuOzDX6j9YkKPToQ6gQKD1mqYunF3BcM0rTDfHN8SqXX++1JH5idaL9612D4ZM8h759fPIgDPFb3bHAvkeGAEGyOEDkH6d8XkjXWdKA/bcSrV6T1dwvMefxwS0sqoNGoCz0oRfDFnIYnVFH9HUwOmrtArD2p2Mw=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2256.namprd13.prod.outlook.com (52.135.93.157) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.9; Sun, 4 Nov 2018 13:56:41 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.028; Sun, 4 Nov 2018
 13:56:40 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client bugfix for 4.20
Thread-Topic: [GIT PULL] Please pull NFS client bugfix for 4.20
Thread-Index: AQHUdEY2obJr6QuzUEenmczogDfiGg==
Date:   Sun, 4 Nov 2018 13:56:40 +0000
Message-ID: <9d585276a55d788b98ba425910cd4a05a9e5cf99.camel@hammerspace.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2256;6:vLnZEbaH0cxtXa3nQoR80V6lgWR4iROQIuIl6DamIUS3m0OgtiVoAwO+5OLFe3LdbWD+T0KL4bv9p1UsbG6q96612uwjrOVrix1I3LmVrddTru8DGCvfMpZfvJCxMKSzvhZ/OYaFxDSjCwBQOx6jknuPMolIZ6RgykqdILDEbeBXd9RTbNGECa6x6ciJmjX0LTxJ38vSSwEMFcJdGK4TWf/tfzPGh4+nZ7jJf1C+FWzUwi8wJY8uFmaBPVGwZtUHrlfJ97gXuHbmfxkNe64pkwhUYHrJNxl82wyLlMRZAE7V5nzVgAemkqKwhi9L17hsAt/lKaBZhsjKuWYqui7pMZ1HSCuuk65+6zAldkdJa/5e0ddp12vrfYhzOtY72ZkmXyAq1jGCXcXHeHshwDW7FpE8+3VXlweB9afeefSmDrgcI/NdHX5ySVP42G+8asAFvfuFb/y6MPNwMYEmQvXkzg==;5:1orrWEfq0su0fqVyZTIDo+9iEZPur2jELxYWY4IJmclKbTl6Bf+2eZw9+q/IGh7wZJukVbi4Fe/oh4W+bOG9hT7qKTHhB52DDxj1QWh7ssN9k5xjyN/T86WdGCdrKGFpJJDrWP/Z5lKQICaz7UBI35XFLpTddapwOERy3TOdvHY=;7:QUk0zJ1ZGzPV/hblTZML9f82X42DOwVbMVh4QdBRagf0P0dH3A416/9ZpW0J6AbbjgWQL88tmm5UB8dyaaH1kQ7B2dj5yDDQBQdx/O1BjPOxXP9Y1vQLOVaa+Fdji5fyz785H+UHhfN3SN4dQCvUvA==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: f7e6399b-843b-49a5-5210-08d6425d58d3
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(5600074)(711020)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2256;
x-ms-traffictypediagnostic: SN6PR13MB2256:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-microsoft-antispam-prvs: <SN6PR13MB22561FA34DDC7F2050D1E3C8B8C90@SN6PR13MB2256.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(5213294742642);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(3231382)(944501410)(52105095)(93006095)(93001095)(10201501046)(3002001)(148016)(149066)(150057)(6041310)(201703131423095)(20161123555045)(201703061421075)(20161123558120)(20161123562045)(20161123564045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2256;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2256;
x-forefront-prvs: 084674B2CF
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(376002)(366004)(136003)(199004)(189003)(8936002)(7736002)(105586002)(102836004)(305945005)(6506007)(106356001)(68736007)(86362001)(5660300001)(6916009)(54906003)(71190400001)(71200400001)(66066001)(118296001)(99286004)(81156014)(81166006)(1730700003)(8676002)(53936002)(4326008)(25786009)(14454004)(6512007)(97736004)(5640700003)(2501003)(4001150100001)(256004)(6486002)(6436002)(486006)(2616005)(6116002)(2906002)(2351001)(508600001)(26005)(36756003)(2900100001)(186003)(3846002)(476003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2256;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: YPqjgZlD0kOabM23GpGgy8OwH15u9jJCBSvC8R+XEFV678Zb/ElrjkV2xxIbyH+hEp9nImUJDU95dbozwo52hyDebkrjYwzIh2lkMEJF47IB7D4/YQgkgynykXMkv/lQGzXZGZe8+YsZUnI6fEp8coEV4vsZaXM7X+2QElmVEvV67z7wULb8caXwZoL2kVsHvwgBW35kGmF5bteFh+iDpsp8T7HG+ydMKsPp/AN2ujVHiF/blhhv9yKVCJchKkiVggkewNDfXVCXh3u4mNJA6ZZcqz987n3SKb+gO5gkmPsIdCcuAqWJWR4RTt30L3ewpTD5s35kbzpRqjPnkoBqeUvNUX+I+AzLSOg3W+v/2V8=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <C7CF5FFCDFC6394C9DEEC4BC0213D0CF@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: f7e6399b-843b-49a5-5210-08d6425d58d3
X-MS-Exchange-CrossTenant-originalarrivaltime: 04 Nov 2018 13:56:40.7208
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2256
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgODZiYmQ3NDIy
YWU2YTMzNzM1ZGY2ODQ2ZmQ2ODVlNDY2ODZkYTcxNDoNCg0KICBORlM6IGNoYW5nZSBzaWduIG9m
IG5mc19maCBsZW5ndGggKDIwMTgtMTAtMjMgMTI6MjI6MjEgLTA0MDApDQoNCmFyZSBhdmFpbGFi
bGUgaW4gdGhlIEdpdCByZXBvc2l0b3J5IGF0Og0KDQogIGdpdDovL2dpdC5saW51eC1uZnMub3Jn
L3Byb2plY3RzL3Ryb25kbXkvbGludXgtbmZzLmdpdCB0YWdzL25mcy1mb3ItNC4yMC0yDQoNCmZv
ciB5b3UgdG8gZmV0Y2ggY2hhbmdlcyB1cCB0byBkMzc4N2FmMjg5Yzg1MzgxY2MwNDhjYjhjNTZi
NjcyNjBkYmJjNDM2Og0KDQogIE5GUzogZml4IHNwZWxsaW5nIG1pc3Rha2UsIEVBQ0NFU1MgLT4g
RUFDQ0VTICgyMDE4LTExLTAxIDE0OjA3OjA2IC0wNDAwKQ0KDQpUaGFua3MsDQogIFRyb25kDQoN
Ci0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0NCk5GUyBjbGllbnQgYnVnZml4ZXMgZm9yIExpbnV4IDQuMjANCg0KSGlnaGxpZ2h0
cyBpbmNsdWRlOg0KDQpCdWdmaXhlczoNCi0gRml4IGJ1aWxkIGlzc3VlcyBvbiBhcmNoaXRlY3R1
cmVzIHRoYXQgZG9uJ3QgcHJvdmlkZSA2NC1iaXQgY21weGNoZw0KDQpDbGVhbnVwczoNCi0gRml4
IGEgc3BlbGxpbmcgbWlzdGFrZQ0KDQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQpDb2xpbiBJYW4gS2luZyAoMSk6DQogICAg
ICBORlM6IGZpeCBzcGVsbGluZyBtaXN0YWtlLCBFQUNDRVNTIC0+IEVBQ0NFUw0KDQpQYXVsIEJ1
cnRvbiAoMSk6DQogICAgICBTVU5SUEM6IFVzZSBhdG9taWMoNjQpX3QgZm9yIHNlcV9zZW5kKDY0
KQ0KDQogZnMvbmZzL25mczRwcm9jLmMgICAgICAgICAgICAgICAgICAgfCAgMiArLQ0KIGluY2x1
ZGUvbGludXgvc3VucnBjL2dzc19rcmI1LmggICAgIHwgIDcgKystLS0tLQ0KIG5ldC9zdW5ycGMv
YXV0aF9nc3MvZ3NzX2tyYjVfbWVjaC5jIHwgMTYgKysrKysrKysrKy0tLS0tLQ0KIG5ldC9zdW5y
cGMvYXV0aF9nc3MvZ3NzX2tyYjVfc2VhbC5jIHwgMjggKystLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLQ0KIG5ldC9zdW5ycGMvYXV0aF9nc3MvZ3NzX2tyYjVfd3JhcC5jIHwgIDQgKystLQ0KIDUg
ZmlsZXMgY2hhbmdlZCwgMTcgaW5zZXJ0aW9ucygrKSwgNDAgZGVsZXRpb25zKC0pDQotLSANClRy
b25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0K
dHJvbmQubXlrbGVidXN0QGhhbW1lcnNwYWNlLmNvbQ0KDQoNCg==
