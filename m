Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C127C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:42:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 12510206A3
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 22:42:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="hKiyymRE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726035AbfBUWmD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 17:42:03 -0500
Received: from mail-eopbgr730125.outbound.protection.outlook.com ([40.107.73.125]:34159
        "EHLO NAM05-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725961AbfBUWmD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 17:42:03 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=6hh8oCINMIqdpYEy275bmfa3c8Eta3IkjhB3Gu2wd/Y=;
 b=hKiyymRElxqIluOI1VP00UGbo7GBeIzBT0lEUZ34+ijNv6QahSarzEYUXTI5gYa+h2SHJLZWYkJPClo7zyKvAvo/+aOsw7bxz8Sx7aN7RVZ+4+x3/35YSLGuBIBuxwE2ArgKGDg6rxJTcj12d8uUCjr3kxshZQwwFcSR/c9XCGQ=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2400.namprd13.prod.outlook.com (52.135.94.156) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.11; Thu, 21 Feb 2019 22:41:59 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Thu, 21 Feb 2019
 22:41:59 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "ebiederm@xmission.com" <ebiederm@xmission.com>
CC:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] fs/nfs: Fix nfs_parse_devname to not modify it's argument
Thread-Topic: [PATCH] fs/nfs: Fix nfs_parse_devname to not modify it's
 argument
Thread-Index: AQHUuKPu5D8CFXMurkWINo+eOS5XqKXq/AWA
Date:   Thu, 21 Feb 2019 22:41:59 +0000
Message-ID: <0625ae525b9a9aa77c40b697fb39563163ee6d01.camel@hammerspace.com>
References: <87fttap7qp.fsf@xmission.com>
In-Reply-To: <87fttap7qp.fsf@xmission.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a6c39e88-a963-4ad2-002e-08d6984dca35
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2400;
x-ms-traffictypediagnostic: SN6PR13MB2400:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNDAwOzIzOlc4QXF4bzJmUTdQZ3pkQVFrNnh1RnVsMEZN?=
 =?utf-8?B?THlVTldwcnU5U0pUaHFjUkJHRVB5azhrdmFqOEZnS3Bnd0plamZQbGJRNndv?=
 =?utf-8?B?bUt5S2lTbmoyQ3d6MDFPeTg4RHVGc01zaWZRM1pHN3FraVdMdWNVcjZjKzAy?=
 =?utf-8?B?Y3VQbmo2SEtPMWt6cDEzWHNmNTQrbDdKWGZVQzgzaDZjdDB6Y3FIUEl0WG5Y?=
 =?utf-8?B?VmlGY0VWL29ORzkrSjcxeDZhUjkwdnFnY2tOYlF1Rjg3T3E0SzVrT2xMWWxJ?=
 =?utf-8?B?YkloNk1UNzRSOVgvOGg4Y0pycTZTT3d5ZlVyckFwYUJpWmtLV3F4ZFIzZmlq?=
 =?utf-8?B?SEE2dTByZzJiQXh2RGcxV2IvTy85alk1SEZkbXMwc3dWcXFQQk5ldG9IeEJy?=
 =?utf-8?B?V0MwSythRzlVS1UrN1hCZTBnQ1J1a0lXa3UzeHYvb25SWlJjNVRhRVlCR0tY?=
 =?utf-8?B?SlZOTnZodXZmSHFPNEZvY3o0cFlmM2Q0Y3BRbGlpMHpoL28zQTU5N1pqMGV2?=
 =?utf-8?B?QXBhNWErZ0xKZWVxQUgyMjd3UVc5SlpYMXdYUVdmM2RnWHJMM25OMUttcDd3?=
 =?utf-8?B?VTg2LzJ1SldETXg4d3Zadjdiclh6VG5GRTZ0S3dqWjJFUUpxQmxyNG9LTlF1?=
 =?utf-8?B?VlgwaVlRZHRrNS9zUk9rMzNUZFNUVkc2K3dnRXEzSjU0UGt4OHJyeUlxcmxs?=
 =?utf-8?B?dHJwUEVUbmlBMW9vOGhpZU0reDU1elNwUXByb2p0VzdnMVlDN05YYmlLdlpP?=
 =?utf-8?B?VWJsRFJqV0pOSVQvQzRYd3ltM2lyZm1abXcrc0x0TS9uNGFDWXdQRzRoR1Z1?=
 =?utf-8?B?UHV3QjJzOEZ1K2Evd2pPam8zQWxJTHR4b28xdFV6dHRuWWZIckMwM0k1RzlK?=
 =?utf-8?B?dUVjZmZpajBvSi85SUkxcXdFYlJuS1hiazI4UVhHNUFJL0FrUDVKQitPVmRR?=
 =?utf-8?B?MDJCczhOWFdENTRuM0kzRVQzZGJsTFN2c2laTVY5TERNaUs2MjE2QnVGUmEz?=
 =?utf-8?B?R2tVY1FpdGlrbDRhSXBObHBqV0VvRE1rNllWNkgwV296NFZpUnJTdlhPZk9V?=
 =?utf-8?B?dUJhcStMVVZUZi9hK1ExMEkxb3ozd0VBMU1JY29kY3E2UFp1bTZDUFB4T3or?=
 =?utf-8?B?dGtzNjJxK1c3UmxuQ2VkZE5IQnNVU2QrNlpzbWlCbVh5eTcrb3lzZlZ6cEls?=
 =?utf-8?B?N0hqZVZaV0kzeXErazkyMk4reklEWlNpSXJmc1VsT3FiQ1gyYlRKblVwRnRa?=
 =?utf-8?B?Yk9WY0tSTkFrMHY1L3dtWWpsVGcvbTd3dE04YnJlazFlWU1UWVEvVUVmb3F1?=
 =?utf-8?B?VE8rdHdaZzQ1QzY2eTlZdERrVFJPSklNNWMzTUgxWDNRU1ByTlliOWg2ekVo?=
 =?utf-8?B?NmJ6MWFGUExVV1FjVTk2a21QVm9LOHRwRzNVSTBqL29UNjcremc2blI1cndl?=
 =?utf-8?B?U1RPZDQ0ZWpzZTRyQzVmUVN6aXlUN0xRaHp3d1UydXRDQ2xtc0pKUDNwOHRt?=
 =?utf-8?B?NHpPaTlJVFNwUHZKbHVIS3l3NmNJS0VjSm5LMlRtRldMSVhWNnhzU3A0ZnNv?=
 =?utf-8?B?M28wQ1hpQ0V3SW1TZzAvYW5SVWVBWTZUV2h0TzNSMVMrZmtRM1E4eXkreFh5?=
 =?utf-8?B?MEp6NitUZk1qVDdsR0l2V0xQWG5jTGNsQ2J2OGIxRHY5QXMzdEZnaUV3PT0=?=
x-microsoft-antispam-prvs: <SN6PR13MB2400AA4C3E1A124DCA135F07B87E0@SN6PR13MB2400.namprd13.prod.outlook.com>
x-forefront-prvs: 09555FB1AD
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(366004)(346002)(39830400003)(396003)(136003)(199004)(189003)(4326008)(6512007)(106356001)(105586002)(81156014)(81166006)(186003)(25786009)(6436002)(478600001)(68736007)(6486002)(486006)(2616005)(256004)(476003)(8676002)(53936002)(446003)(2501003)(11346002)(6506007)(3846002)(6116002)(110136005)(54906003)(102836004)(99286004)(76176011)(6246003)(229853002)(118296001)(8936002)(26005)(14454004)(36756003)(316002)(7736002)(305945005)(86362001)(71190400001)(71200400001)(97736004)(4744005)(66066001)(2906002)(5660300002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2400;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: jdrZ3iBMSxYec+q9U5VyiYwM3o7Kmo6om6TuimNktN/Vw+qw2f3mghTYAtZy8DaD8j3tJWI8yYgRqMQWi6Sd032q51eqkQzJwQAP5WCmXY2rEatzQG4FkNNRlsmSYzcoON41p+054kR7Ua/l9aiYaat9Bebm+q/XUGiWQPKJ0waSM/evocj7lvGU89WFWAeCo1cS8tzk72j8ANRYjCzGBJqXSyL+AT7J5tYp8U8VrSP65Gf6CmN6+0YrKqE99EgAXW8Mcon5ZbQYesvR4bn3OwuFA/daMidQqrcHmKKPXPP8lfjIyAy9bXzgKZXbMnlc2MVpMWNFOU3+bzJh96wha9glg8gBu8Jm8UyEzVh+eIA3LMxDWRnUxLnpMymmrNGNT4MEg7xRUoaKN0ahp38Q1yxvrO5oMv5ODQoAlwEne80=
Content-Type: text/plain; charset="utf-8"
Content-ID: <9BC85668D0D4AA4A85E0B45C8873DF85@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: a6c39e88-a963-4ad2-002e-08d6984dca35
X-MS-Exchange-CrossTenant-originalarrivaltime: 21 Feb 2019 22:41:59.0687
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2400
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAxLTMwIGF0IDA3OjU4IC0wNjAwLCBFcmljIFcuIEJpZWRlcm1hbiB3cm90
ZToNCj4gSW4gdGhlIHJhcmUgYW5kIHVuc3VwcG9ydGVkIGNhc2Ugb2YgYSBob3N0bmFtZSBsaXN0
IG5mc19wYXJzZV9kZXZuYW1lDQo+IHdpbGwgbW9kaWZ5IGRldl9uYW1lLiAgVGhlcmUgaXMgbm8g
bmVlZCB0byBtb2RpZnkgZGV2X25hbWUgYXMgdGhlIGFsbA0KPiB0aGF0IGlzIGJlaW5nIGNvbXB1
dGVkIGlzIHRoZSBsZW5ndGggb2YgdGhlIGhvc3RuYW1lLCBzbyB0aGUgY29tcHV0ZWQNCj4gbGVu
Z3RoIGNhbiBqdXN0IGJlIHNob3J0ZWQuDQo+IA0KPiBGaXhlczogZGMwNDU4OTgyN2Y3ICgiTkZT
OiBVc2UgY29tbW9uIGRldmljZSBuYW1lIHBhcnNpbmcgbG9naWMgZm9yDQo+IE5GU3Y0IGFuZCBO
RlN2Mi92MyIpDQo+IFNpZ25lZC1vZmYtYnk6ICJFcmljIFcuIEJpZWRlcm1hbiIgPGViaWVkZXJt
QHhtaXNzaW9uLmNvbT4NCg0KVGhhbmtzIEVyaWMhIEFwcGxpZWQgdG8gbXkgbGludXgtbmV4dCBi
cmFuY2ggZm9yIGluY2x1c2lvbiBpbiB0aGUgNS4xDQptZXJnZSB3aW5kb3cuDQoNCi0tIA0KVHJv
bmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0
cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3BhY2UuY29tDQoNCg0K
