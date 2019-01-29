Return-Path: <SRS0=GD9Z=QF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E80BBC169C4
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 20:49:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 85C0C2087E
	for <linux-nfs@archiver.kernel.org>; Tue, 29 Jan 2019 20:49:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="YeOGiyVk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727342AbfA2Utb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 29 Jan 2019 15:49:31 -0500
Received: from mail-eopbgr740121.outbound.protection.outlook.com ([40.107.74.121]:36065
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727339AbfA2Uta (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Jan 2019 15:49:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=NAtlr8g5RaEsyJ/a05qGpCStC+SWYi5XqVKdlapfXJU=;
 b=YeOGiyVkn1eBwjxSVXhkq7Q3hzWdH5yxkmVAwZcSI2EmfzL6T+3yFVpPxLFQamhpMJl4U5z86JV5zpJyTs8vgwh+AoefLNyqFJO2HCTYbUYloVUbsMSJrlG7MSRFTld/PU2bAc/RhVojO9Jn3i23hCQiw+TBklRX7UyLYWSeg7c=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2318.namprd13.prod.outlook.com (52.135.94.25) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1580.13; Tue, 29 Jan 2019 20:49:26 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::7dd2:1e4f:2de1:eb27%4]) with mapi id 15.20.1580.016; Tue, 29 Jan 2019
 20:49:26 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bcodding@redhat.com" <bcodding@redhat.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Always return the error that truncates a flushing
 page
Thread-Topic: [PATCH] NFS: Always return the error that truncates a flushing
 page
Thread-Index: AQHUtlPAp5BRF0OngU+mS50qV7mcpqXE+ciAgAAPqQCAAbIhgA==
Date:   Tue, 29 Jan 2019 20:49:26 +0000
Message-ID: <e87423e25a6aeff640199eb1a776194cfef8a041.camel@hammerspace.com>
References: <1cbf359e173a9f93e7c858faa43e623dda3858df.1548602308.git.bcodding@redhat.com>
         <9fc3d4ee7d8eafdfdb7b7c1397ecb25dd22e12b7.camel@hammerspace.com>
         <4512E750-0B6F-4842-B7B8-469FF04FBB00@redhat.com>
In-Reply-To: <4512E750-0B6F-4842-B7B8-469FF04FBB00@redhat.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2318;6:00snywurYdAWkzYFb0zCLvkkjVK3BtMX50IziWJdqxa5Thnx2jp4EmCtlKs5ow3lOUW4gVPmEjnxYe92DgUui2/mHbqGIJhHnAlyO7fHcteeZWbXSs44b6N4JoYXfttWqi+NhS2NJmbtoVwkBm3fCPj41ne281x3gP64MgST9/ZzWOtE0dfu/TxF2SmhVYZRsbt9jEYyJFh16L9yJDWmdvY7MO14Wq0DNVOpvZxwZeayJfuxmbmx1w8szDNu/p/kt268KZvOjP7IDV9Z8zXYJBOgeKOLja2zfg3JwDBMWge6k+4OwEwP4pvV0oMZJO0mlPzaffNmeBwSZFJ/lcqQKIbRdl1mUWiHsARkk+sDHNE5hOaLDGG2a+YskyD7vNkVAgbpy9uxTc4kIgA/soWn4ftDdHzz+cRfXmpBflDVhrwZZYF/24g27Cvp8+OD3a6ALo5rZJEDv82o3JeSErElSQ==;5:btkV3WtDg2VNGSLmQxhJvKgYb5KsfztyWt1qCaYAUIucdiLHjy1+ymGfZaFFTeprpp36bmpKDTAQFwifNcDZn81/YXYGm7SwV4xjdbHnisDoBv0l06WXQYzxuJNBL3++mA8nCoK0/Wk7T6czr9Ugw45SybFfAgXf54rUudClsJHl20rUlpZ5A1nlZUe3U5pLq4T9QriVh/TWVmO6o4Kt+w==;7:TQTTS0WveKLutSz8kVRsYXwBWoYbkSEVJP7zMA86TOny5/AbvN1Tc0+clER7Wgd//i5zqSD6zr4QKW9X2qSoHCe5G+SsWL6AYpmDtTtukMKYIrRBRiXvWi/yXId7nybLsO9yoj3wp0YQTt7MuLc2Bw==
x-ms-office365-filtering-correlation-id: 8cc84f0b-fa1c-44c3-573c-08d6862b41fe
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2318;
x-ms-traffictypediagnostic: SN6PR13MB2318:
x-microsoft-antispam-prvs: <SN6PR13MB231825719DCFAE971408C0CDB8970@SN6PR13MB2318.namprd13.prod.outlook.com>
x-forefront-prvs: 093290AD39
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(39840400004)(346002)(376002)(136003)(199004)(189003)(81156014)(118296001)(81166006)(8676002)(1730700003)(8936002)(76176011)(305945005)(229853002)(7736002)(446003)(54906003)(11346002)(36756003)(66066001)(2616005)(86362001)(476003)(97736004)(6916009)(316002)(4744005)(105586002)(186003)(106356001)(71200400001)(71190400001)(256004)(68736007)(26005)(2501003)(486006)(99286004)(102836004)(53546011)(6486002)(2906002)(478600001)(53936002)(6116002)(4326008)(6512007)(6436002)(6246003)(2351001)(5640700003)(14454004)(3846002)(25786009)(6506007);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2318;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: XCymwemBQVUykJzpcJYIhyAJ9dGn5K1N0Q6Wlk209BL7z1/7wQWEbSnSMvFhsjx6s4imWWBIMAJrRY/013HU2tOp7bhihMpoqowkPwGoIrK+7ejitXZJxAxFRf/CPQDU22GnuFkTwCEg8x0eocubKdMmiMwdHI9JFD3p6FaBfPcr8pp8j6Bxm+6khG3RtFU3+71WyBiitxmIu8lWMRsTaZT5fRZ8mI17XXchMYrYiMe9lzQ8QopECLHG4aqf+tgefCWWS1ogDDSEYMhbqIPqXI9kSCj9fkLbYzXpIBTh6ZBSLSFJHndJ3LszxPlrafMdzYpYxd1kBcGjAZNoObfTRFUzAPKLPudd6K6H0pqvNVrIKsayKbW6KX5vXZ74FcKXKdfaXPoSpi4VL7Ss7wPY27H0O4NCt3+x0Y1uMeltwFM=
Content-Type: text/plain; charset="utf-8"
Content-ID: <7A86E202B376DC49A410399153B60EBE@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 8cc84f0b-fa1c-44c3-573c-08d6862b41fe
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 Jan 2019 20:49:26.6986
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2318
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gTW9uLCAyMDE5LTAxLTI4IGF0IDEzOjU1IC0wNTAwLCBCZW5qYW1pbiBDb2RkaW5ndG9uIHdy
b3RlOg0KPiBPbiAyOCBKYW4gMjAxOSwgYXQgMTI6NTksIFRyb25kIE15a2xlYnVzdCB3cm90ZToN
Cj4gPiBIaSBCZW4NCj4gPiANCj4gPiBXZSB3ZXJlIGFwcGFyZW50bHkgYm90aCBsb29raW5nIGF0
IHRoZSBzYW1lIGNvZGUgbGFzdCB3ZWVrIOKYui4gSQ0KPiA+IGhhdmUgYQ0KPiA+IHNpbWlsYXIg
cGF0Y2gsIGJ1dCB0aGF0IGFsc28gZml4ZXMgYSBzaW1pbGFyIGNsb2JiZXJpbmcgaXNzdWUgd2l0
aA0KPiA+IHRoZQ0KPiA+IG5mc19lcnJvcl9pc19mYXRhbCgpIGVycm9yIGp1c3QgYSBmZXcgbGlu
ZXMgZnVydGhlciBkb3duLg0KPiA+IA0KPiA+IFdpdGhvdXQgdGhlIGV4dHJhIGh1bmssIHdlIGNv
dWxkIGVuZCB1cCBjb252ZXJ0aW5nIGFuIGludGVycnVwdGVkDQo+ID4gY2FsbA0KPiA+IGludG8g
YSAnc3VjY2Vzc2Z1bCcgd3JpdGUuDQo+ID4gDQo+ID4gQ2hlZXJzDQo+ID4gICBUcm9uZA0KPiAN
Cj4gTG9va3MgcmlnaHQgdG8gbWUuICBJIGhvcGUgeW91J2xsIHRha2UgdGhlIEZpeGVzIGFuZCBz
dGFibGUgdmVyc2lvbg0KPiBmcm9tDQo+IG15IHBhdGNoLCB3aGljaCB3aWxsIGNvdmVyIHRoZSBw
cm9ibGVtIEknbSBzZWVpbmcuDQo+IA0KPiBSZXZpZXdlZC1ieTogQmVuamFtaW4gQ29kZGluZ3Rv
biA8YmNvZGRpbmdAcmVkaGF0LmNvbT4NCj4gDQoNCkF0IGZpcnN0LCBJIHRob3VnaHQgSSdkIGhh
dmUgdG8gc3BsaXQgdGhpcyBwYXRjaCBpbiAyIHNvIHRoYXQgaXQgY291bGQNCmFwcGx5IHRvIDQu
MTEgYW5kIDQuMTIsIGJ1dCBpdCBsb29rcyB0byBtZSBhcyBpZiB0aGUgY29tbWl0IGZyb20gdGhl
DQpGaXhlcyBsaW5lIHlvdSB3ZXJlIHNob3dpbmcgaXMgYWN0dWFsbHkgb25seSBwcmVzZW50IGlu
IDQuMTIgYW5kIGxhdGVyLg0KQW0gSSB3cm9uZz8NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxp
bnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xlYnVzdEBo
YW1tZXJzcGFjZS5jb20NCg0KDQo=
