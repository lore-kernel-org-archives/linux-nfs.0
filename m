Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38A54C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:55:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D2BF621850
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:55:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Bi5od/LC"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726674AbeLROzV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:55:21 -0500
Received: from mail-eopbgr820107.outbound.protection.outlook.com ([40.107.82.107]:18784
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726426AbeLROzU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:55:20 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=/+2tYnuHlAqCzI0OAIi5WVP3H81XAI2wyCY8OxNgz3E=;
 b=Bi5od/LC3oGkt1GrDu7p6SngXeMcqNJGDEEcFfgCJxzXWAh5WQeCLhIXJO5Ip32tLfpgy1xW14BNMtkOoql4iOJ8J1LWmAOfS53tY4f4UiuTh4ERyJPRigcaNCWnDOCga3QthIAxpiZgnvypvDCjcjcNV0LMCdbDdsiQQp+FkGg=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2351.namprd13.prod.outlook.com (52.135.94.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1446.15; Tue, 18 Dec 2018 14:55:15 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::25d2:c29b:5dfa:e85f%4]) with mapi id 15.20.1446.015; Tue, 18 Dec 2018
 14:55:15 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        "vvs@virtuozzo.com" <vvs@virtuozzo.com>
CC:     "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "khorenko@virtuozzo.com" <khorenko@virtuozzo.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "eshatokhin@virtuozzo.com" <eshatokhin@virtuozzo.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "jlayton@kernel.org" <jlayton@kernel.org>
Subject: Re: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Topic: [PATCH 1/4] nfs: use-after-free in svc_process_common()
Thread-Index: AQHUliTq8x5/j6ovkEmcMIRcXEAVYaWDeL8AgACVn4CAAGV+AIAAHc0AgAAFZwA=
Date:   Tue, 18 Dec 2018 14:55:15 +0000
Message-ID: <068f1741afc54367853a2e4501fd95c2ab12a989.camel@hammerspace.com>
References: <134cf19c-e698-abed-02de-1659f9a5d4fb@virtuozzo.com>
         <20181217215026.GA8564@fieldses.org>
         <cb8d51ae-2745-58ca-8b4d-86c7a4bd2ffe@virtuozzo.com>
         <67f477b704d34b369f0530891a219f383f964001.camel@hammerspace.com>
         <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
In-Reply-To: <4d878140-02c0-e306-fee6-1573d9fdecf2@virtuozzo.com>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2351;6:bXy40HbDaAyJzITP5V2PNJ/NubWrmd3qkkO36szOhWdAz5BM64kSbMdzZqXlsCyQeyiSwLIgyKdEDzm6cb0n9IPBJ6LNe4yPE9Uns+6IbKJzIeBfln/YAUJp/J/xw5c+FXA08al9/lnv2wCpNWVB5ukHmKY2qoyb4gyieYmcECEs8Twzu8Pahn8+kwaT4QJXgDWwPtncgY9k/WGAIKYLB9MyAZIt2ySe/aOj2o8GI7Y4T18xZlHc761fm6ggNzBPDBIXYsNIbQ83JKktTmqAI7tHTgUCPzLUCFKri/mINYlHgYtUZ0UWbTXG3JBsFn1zpwnKe6KyPM1SF3GnhN9FX6GTQh+WjeD8mDTTgOTr7VjjEHUK32mgjjGe9zsnL1NdqVFxYV8U3Ny5D7wnnOHXWzMkrtEriYRvJNgJuAkIQ6BvWtav9KMshh0MND0bhoTtjjk2ZOFmUTCK79NbYgJ+EQ==;5:15hOFZP5zZMXWZJ/0AceaKRzpQeOwRxr8kJzYcdS/loswfVXkbrSXnZtTetwbJWe6T66WUud9xdNCvt76ddJpf9svjb55H2j6crxvlbG7Avbw96DSYmVpS44RuKvbOBD6Z8aB7fAONS60QBYOt7ghVxDr++qSO6Sbnwsf3yCMmk=;7:JVLix/F4IjR4GmVB4M6mIgkiCEhwVGEOAjckR4clFvZ82kutjE/Nhy8nemT3pm3lueirhP8PRYyCHRZ5MjLhzHijDPP6V/aYS4ehXiVt9BCv05D4Eap2q42wqV0COOa5ObqaRCyYTWDHdpeoZBKv/g==
x-ms-exchange-antispam-srfa-diagnostics: SOS;
x-ms-office365-filtering-correlation-id: 7345c584-d556-4a0d-6b30-08d664f8d1c8
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2351;
x-ms-traffictypediagnostic: SN6PR13MB2351:
x-microsoft-antispam-prvs: <SN6PR13MB2351EA88651AFA43E821C0F2B8BD0@SN6PR13MB2351.namprd13.prod.outlook.com>
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(3230021)(999002)(6040522)(2401047)(5005006)(8121501046)(93006095)(93001095)(3002001)(3231475)(944501520)(52105112)(10201501046)(148016)(149066)(150057)(6041310)(20161123564045)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123558120)(20161123562045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2351;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2351;
x-forefront-prvs: 08902E536D
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(39840400004)(376002)(136003)(366004)(396003)(199004)(189003)(2906002)(53546011)(486006)(106356001)(11346002)(446003)(102836004)(99286004)(76176011)(6116002)(105586002)(3846002)(6506007)(25786009)(36756003)(2616005)(8676002)(110136005)(66066001)(93886005)(6436002)(68736007)(118296001)(54906003)(26005)(8936002)(81166006)(186003)(229853002)(81156014)(478600001)(316002)(6486002)(14454004)(86362001)(4326008)(97736004)(7736002)(305945005)(71200400001)(71190400001)(2501003)(6512007)(5660300001)(53936002)(14444005)(4001150100001)(256004)(476003)(6246003);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2351;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: DwaPK9pgsyQFH6ZBSinzabN3WQgr1Z4/pj+XcHtzV3C36UyLOjL/F8jWq4+cxWva1+rWdo0v3uWnHuQ2FuZSbnChB6juLaRms/yh67vjcNtepzUrPvX6tHr4mlpeWrDCQD3+3lXCF4GSchg6R58LRKpFlYLhS3UgBJo9mCTBdCtsp7IrqsPaZq0WAcbPPjRf5ip6pSg8Rkw9QiyYWzP04AUiX5SP1aiTxpfTI3FOQ3w63USkBt9dzEHYQjsKAHXj9fnAdIHQ07AlnBsusIvd0WYIgapwiI4nQYHhXd4Bx4HG4uHPsY2cg34dcC3tLSz2
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <C94A9910222A304E9BF743E71F318B33@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 7345c584-d556-4a0d-6b30-08d664f8d1c8
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Dec 2018 14:55:15.2042
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2351
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVHVlLCAyMDE4LTEyLTE4IGF0IDE3OjM1ICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0K
PiBPbiAxMi8xOC8xOCAzOjQ5IFBNLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+ID4gT24gVHVl
LCAyMDE4LTEyLTE4IGF0IDA5OjQ1ICswMzAwLCBWYXNpbHkgQXZlcmluIHdyb3RlOg0KPiA+ID4g
T24gMTIvMTgvMTggMTI6NTAgQU0sIEouIEJydWNlIEZpZWxkcyB3cm90ZToNCj4gPiA+ID4gT24g
TW9uLCBEZWMgMTcsIDIwMTggYXQgMDc6MjM6NTRQTSArMDMwMCwgVmFzaWx5IEF2ZXJpbiB3cm90
ZToNCj4gPiA+ID4gPiBpZiBub2RlIGhhdmUgTkZTdjQxKyBtb3VudHMgaW5zaWRlIHNldmVyYWwg
bmV0IG5hbWVzcGFjZXMNCj4gPiA+ID4gPiBpdCBjYW4gbGVhZCB0byB1c2UtYWZ0ZXItZnJlZSBp
biBzdmNfcHJvY2Vzc19jb21tb24oKQ0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IHN2Y19wcm9jZXNz
X2NvbW1vbigpIA0KPiA+ID4gPiA+ICAgICAgICAgLyogU2V0dXAgcmVwbHkgaGVhZGVyICovDQo+
ID4gPiA+ID4gICAgICAgICBycXN0cC0+cnFfeHBydC0+eHB0X29wcy0+eHBvX3ByZXBfcmVwbHlf
aGRyKHJxc3RwKTsNCj4gPiA+ID4gPiA8PDwNCj4gPiA+ID4gPiBIRVJFDQo+ID4gPiA+ID4gDQo+
ID4gPiA+ID4gc3ZjX3Byb2Nlc3NfY29tbW9uKCkgY2FuIHVzZSBhbHJlYWR5IGZyZWVkIHJxc3Rw
LT5ycV94cHJ0LA0KPiA+ID4gPiA+IGl0IHdhcyBhc3NpZ25lZCBpbiBiY19zdmNfcHJvY2Vzcygp
IHdoZXJlIGl0IHdhcyB0YWtlbiBmcm9tDQo+ID4gPiA+ID4gc2Vydi0NCj4gPiA+ID4gPiA+IHN2
X2JjX3hwcnQuDQo+ID4gPiA+ID4gDQo+ID4gPiA+ID4gc2VydiBpcyBnbG9iYWwgc3RydWN0dXJl
IGJ1dCBzdl9iY194cHJ0IGlzIGFzc2lnbmVkIHBlci0NCj4gPiA+ID4gPiBuZXRuYW1lc3BhY2Us
DQo+ID4gPiA+ID4gc28gaWYgbmZzdjQxKyBzaGFyZXMgYXJlIG1vdW50ZWQgaW4gc2V2ZXJhbCBj
b250YWluZXJzDQo+ID4gPiA+ID4gdG9nZXRoZXINCj4gPiA+ID4gPiBiY19zdmNfcHJvY2Vzcygp
IGNhbiB1c2Ugd3JvbmcgYmFja2NoYW5uZWwgb3IgZXZlbiBhY2Nlc3MNCj4gPiA+ID4gPiBmcmVl
ZA0KPiA+ID4gPiA+IG1lbW9yeS4NCj4gPiA+ID4gPiANCj4gPiA+ID4gPiBUbyBmaW5kIGNvcnJl
Y3Qgc3ZjX3hwcnQgb2YgY2xpZW50LXJlbGF0ZWQgYmFja2NoYW5uZWwNCj4gPiA+ID4gPiBiY19z
dmNfcHJvY2VzcygpIG5vdyBjYWxscyBuZXcgLmJjX2dldF94cHJ0IGNhbGxiYWNrDQo+ID4gPiA+
ID4gdGhhdCBleGVjdXRlcyBzdmNfZmluZF94cHJ0KCkgd2l0aCBwcm9wZXIgeHBydCBuYW1lLg0K
PiA+ID4gPiANCj4gPiA+ID4gVGhpcyBzdHVmZiBpcyBjb25mdXNpbmcgYW5kIEkgbmVlZCB0byBz
dGFyZSBhdCBpdCBzb21lIG1vcmUNCj4gPiA+ID4gYmVmb3JlDQo+ID4gPiA+IEkNCj4gPiA+ID4g
dW5kZXJzdGFuZCwgYnV0IGl0J3Mgd2VpcmQgdGhhdCB3ZSdkIG5lZWQgdG8gc2VhcmNoIGZvciB0
aGUNCj4gPiA+ID4gcmlnaHQNCj4gPiA+ID4geHBydC4NCj4gPiA+IA0KPiA+ID4gQWxsIE5GUyBj
bGllbnRzIGluIGFsbCBuZXQgbmFtZXNwYWNlcyB1c2VkIHRoZSBzYW1lIG1pbm9ydmVyc2lvbiAN
Cj4gPiA+IHNoYXJlcyBjb21tb24gbmZzX2NhbGxiYWNrX2RhdGEgdGFrZW4gZnJvbSBnbG9iYWwN
Cj4gPiA+IG5mc19jYWxsYmFja19pbmZvDQo+ID4gPiBhcnJheS4NCj4gPiA+IA0KPiA+ID4gTW9y
ZW92ZXIgdGhlc2UgY2xpZW50cyBjYW4gdXNlIGVpdGhlciByZG1hIG9yIG5mcyB0cmFuc3BvcnQs
DQo+ID4gPiBob3dldmVyIG9ubHkgb25lIG9mIHRoZW0gY2FuIGJlIHVzZWQgaW4gb25lIG5ldCBu
YW1lc3BhY2UuDQo+ID4gPiANCj4gPiA+IEVhY2ggbmV0IG5hbWVzcGFjZSBtdXN0IGhhdmUgb3du
IGJhY2tjaGFubmVsLCANCj4gPiA+IGl0IGNhbm5vdCBkZXBlbmQgb24gb3RoZXIgbmV0IG5hbWVz
cGFjZXMsIA0KPiA+ID4gYmVjYXVzZSBhdCBsZWFzdCB0aGV5IGNhbiB1c2UgZGlmZmVyZW50IHRy
YW5zcG9ydHMuDQo+ID4gPiANCj4gPiA+IFNvIG9uZSBzdmNfc2VydiBzaG91bGQgYmUgYWJsZSB0
byBoYW5kbGUgc2V2ZXJhbCAocGVyLW5ldG5zKQ0KPiA+ID4gYmFja2NoYW5uZWxzLg0KPiA+ID4g
DQo+ID4gPiBGcmFua2x5IHNwZWFraW5nIElmIHlvdSBwcmVmZXIgSSBjYW4gZWFzaWx5IGNvbnZl
cnQgZ2xvYmFsDQo+ID4gPiBuZnNfY2FsbGJhY2tfaW5mbyB0byBwZXIgbmV0LW5hbWVzcGFjZS4N
Cj4gPiA+IEkndmUgY2hlY2tlZCwgaXQgd29ya3MgdG9vLiBIb3dldmVyIGN1cnJlbnQgc29sdXRp
b24gbG9va3MgYmV0dGVyDQo+ID4gPiBmb3INCj4gPiA+IG1lLg0KPiA+ID4gDQo+ID4gPiA+IFdl
IGtub3cgd2hpY2ggY29ubmVjdGlvbiB0aGUgYmFja2NoYW5uZWwgcmVxdWVzdCBjYW1lIG92ZXIs
IGFuZA0KPiA+ID4gPiB0aGVyZQ0KPiA+ID4gPiBzaG91bGQgb25seSBiZSBvbmUgYmFja2NoYW5u
ZWwgdXNpbmcgdGhhdCBjb25uZWN0aW9uLCB3aHkgY2FuJ3QNCj4gPiA+ID4gd2UNCj4gPiA+ID4g
ZmluZA0KPiA+ID4gPiBpdCBieSBqdXN0IGNoYXNpbmcgcG9pbnRlcnMgdGhlIHJpZ2h0IHdheT8N
Cj4gPiA+IA0KPiA+ID4gaXQgaXMgYWxsb2NhdGVkIGJ5IHVzaW5nIGZvbGx3aW5nIGNhbGx0cmFj
ZToNCj4gPiA+IG5mc19jYWxsYmFja191cA0KPiA+ID4gIG5mc19jYWxsYmFja191cF9uZXQNCj4g
PiA+ICAgeHBydC0+b3BzLT5iY191cChzZXJ2LCBuZXQpIC0+IHhzX3RjcF9iY191cA0KPiA+ID4g
ICAgc3ZjX2NyZWF0ZV94cHJ0KHNlcnYsICJ0Y3AtYmMiKQ0KPiA+ID4gICAgIF9fc3ZjX3hwb19j
cmVhdGUNCj4gPiA+ICAgICAgc3ZjX2JjX3RjcF9jcmVhdGUNCj4gPiA+ICAgICAgIHN2Y19iY19j
cmVhdGVfc29ja2V0DQo+ID4gPiANCj4gPiA+IEhlcmUgYmFja2NoYW5uZWwncyBzdmNfc29jay9z
dmMveHBydCBpcyBjcmVhdGVkLg0KPiA+ID4gSXQgaXMgcGVyLW5ldG5zIGFuZCB0aGVyZWZvcmUg
aXQgY2Fubm90IGJlIHNhdmVkIGFzIHBvaW50ZXIgb24NCj4gPiA+IGdsb2JhbA0KPiA+ID4gc3Zj
X3NlcnYuDQo+ID4gPiANCj4gPiA+IEl0IGNvdWxkIGJlIHNhdmVkIG9uIHNvbWUgeHBydCByZWxh
dGVkIHRvIGZvcmVjaGFubmVsLA0KPiA+ID4gSSd2ZSBleHBlY3RlZCBpdCB3YXMgZG9uZSBhbHJl
YWR5IC0tIGJ1dCBpdCB3YXMgbm90IGRvbmUuDQo+ID4gPiBJJ3ZlIHRyaWVkIHRvIGZpbmQgYW55
IHdheSB0byBkbyBpdCAtLSBidXQgd2l0aG91dCBzdWNjZXNzLA0KPiA+ID4gYWNjb3JkaW5nIHN0
cnVjdHVyZXMgc2VlbXMgYXJlIG5vdCBhY2Nlc3NpYmxlIGluDQo+ID4gPiBzdmNfYmNfdGNwX2Ny
ZWF0ZS4NCj4gPiA+IA0KPiA+ID4gRmluYWxseSBJJ3ZlIGZvdW5kIHRoYXQgYmFja2NoYW5uZWwn
cyB4cHJ0IGlzIGFkZGVkIGludG8gc2Vydi0NCj4gPiA+ID4gc3ZfcGVybXNvY2tzDQo+ID4gPiBh
bmQgc3ZjX2ZpbmRfeHBydCBjYW4gZmluZCBpdCBieSBuYW1lLg0KPiA+ID4gDQo+ID4gPiBJdCB3
b3VsZCBiZSBncmVhdCBpZiB5b3UgY2FuIGFkdmlzZSBzb21lIG1vcmUgc2ltcGxlIHdheS4gIA0K
PiA+ID4gDQo+ID4gPiA+IE9LLCBJIGRvIG5lZWQgdG8gbG9vayBhdCBpdCBtb3JlLg0KPiA+ID4g
DQo+ID4gPiBJdCBpcyBxdWl0ZSBpbXBvcnRhbnQgZm9yIGNvbnRhaW5lcnMgc28gSSB0aGluayB0
aGlzIHBhdGNoIChvcg0KPiA+ID4gYW55DQo+ID4gPiBhbHRlcm5hdGl2ZSBzb2x1dGlvbikNCj4g
PiA+IHNob3VsZCBiZSBwdXNoZWQgaW4gc3RhYmxlQC4NCj4gPiA+IA0KPiA+IA0KPiA+IFRoZSB3
aG9sZSAibGV0J3Mgc2V0IHVwIHJxc3RwLT5ycV94cHJ0IGZvciB0aGUgYmFjayBjaGFubmVsIiBp
cw0KPiA+IG5vdGhpbmcNCj4gPiBidXQgYSBnaWFudCBoYWNrIGluIG9yZGVyIHRvIHdvcmsgYXJv
dW5kIHRoZSBmYWN0IHRoYXQNCj4gPiBzdmNfcHJvY2Vzc19jb21tb24oKSB1c2VzIGl0IHRvIGZp
bmQgdGhlIHhwdF9vcHMsIGFuZCBwZXJmb3JtIGENCj4gPiBjb3VwbGUNCj4gPiBvZiAobWVhbmlu
Z2xlc3MgZm9yIHRoZSBiYWNrIGNoYW5uZWwpIHRlc3RzIG9mIHhwdF9mbGFncy4NCj4gPiANCj4g
PiBXaGF0IHNheSB3ZSBqdXN0IHBhc3MgaW4gdGhlIHhwdF9vcHMgYXMgYSBwYXJhbWV0ZXIgdG8N
Cj4gPiBzdmNfcHJvY2Vzc19jb21tb24oKSwgYW5kIG1ha2UgdGhvc2UgeHB0X2ZsYWdzIHRlc3Rz
IGNoZWNrIGZvcg0KPiA+IHdoZXRoZXINCj4gPiBvciBub3QgcnFzdHAtPnJxX3hwcnQgaXMgYWN0
dWFsbHkgbm9uLU5VTEw/DQo+IA0KPiBUbyBhY2Nlc3MgcHJvcGVyIHhwdF9mbGFncyBpbnNpZGUg
c3ZjX3Byb2Nlc3NfY29tbW9uKCkgDQo+IHdlIG5lZWQgdG8gcGFzcyBzdmNfeHBydCBpbnN0ZWFk
IG9mIHhwdF9vcHMuDQoNCk5vLiBXZSBkb24ndCBjYXJlIGFib3V0IHhwdF9mbGFncyBmb3IgdGhl
IGJhY2sgY2hhbm5lbCBiZWNhdXNlIHRoZXJlIGlzDQpubyAic2VydmVyIHRyYW5zcG9ydCIuIFRo
ZSBhY3R1YWwgdHJhbnNwb3J0IGlzIHN0b3JlZCBpbiB0aGUgJ3N0cnVjdA0KcnBjX3Jxc3QnLCBh
bmQgaXMgdGhlIHN0cnVjdCBycGNfeHBydCBjb3JyZXNwb25kaW5nIHRvIHRoZSBjbGllbnQNCnNv
Y2tldCBvciBSRE1BIGNoYW5uZWwuDQoNCklPVzogQWxsIHdlIHJlYWxseSBuZWVkIGluIHN2Y19w
cm9jZXNzX2NvbW1vbigpIGlzIHRvIGJlIGFibGUgdG8gcnVuDQpycXN0cC0+cnFfeHBydC0+eHB0
X29wcy0+eHBvX3ByZXBfcmVwbHlfaGRyKCksIGFuZCB0aGF0IGNhbiBiZSBwYXNzZWQNCmVpdGhl
ciBhcyBhIHBvaW50ZXIgdG8gdGhlIHN0cnVjdCBzdmNfeHBydF9vcHMgaXRzZWxmLg0KDQpUaGUg
ZmxhZ3MgYXJlIGlycmVsZXZhbnQsIGJlY2F1c2UgdGhleSByZWZlciB0byBhIHRyYW5zcG9ydCBv
YmplY3QgdGhhdA0KaXNuJ3QgcmVhbC4NCg0KPiANCj4gRG8geW91IG1lYW4gc29tZXRoaW5nIGxp
a2UgZm9sbG93aW5nPw0KPiANCj4gLS0tIGEvbmV0L3N1bnJwYy9zdmMuYw0KPiArKysgYi9uZXQv
c3VucnBjL3N2Yy5jDQo+IEBAIC0xMTQ4LDcgKzExNDgsNyBAQCBzdGF0aWMgX19wcmludGYoMiwz
KSB2b2lkIHN2Y19wcmludGsoc3RydWN0DQo+IHN2Y19ycXN0ICpycXN0cCwgY29uc3QgY2hhciAq
Zm10LCAuLg0KPiAgICogQ29tbW9uIHJvdXRpbmUgZm9yIHByb2Nlc3NpbmcgdGhlIFJQQyByZXF1
ZXN0Lg0KPiAgICovDQo+ICBzdGF0aWMgaW50DQo+IC1zdmNfcHJvY2Vzc19jb21tb24oc3RydWN0
IHN2Y19ycXN0ICpycXN0cCwgc3RydWN0IGt2ZWMgKmFyZ3YsIHN0cnVjdA0KPiBrdmVjICpyZXN2
KQ0KPiArc3ZjX3Byb2Nlc3NfY29tbW9uKHN0cnVjdCBzdmNfcnFzdCAqcnFzdHAsIHN0cnVjdCBr
dmVjICphcmd2LCBzdHJ1Y3QNCj4ga3ZlYyAqcmVzdiwgc3RydWN0IHN2Y194cHJ0ICpzX3hwcnQp
DQo+ICB7DQo+ICAgICAgICAgc3RydWN0IHN2Y19wcm9ncmFtICAgICAgKnByb2dwOw0KPiAgICAg
ICAgIGNvbnN0IHN0cnVjdCBzdmNfdmVyc2lvbiAqdmVyc3AgPSBOVUxMOyAvKiBjb21waWxlciBm
b29kICovDQo+IEBAIC0xMTcyLDcgKzExNzIsNyBAQCBzdmNfcHJvY2Vzc19jb21tb24oc3RydWN0
IHN2Y19ycXN0ICpycXN0cCwNCj4gc3RydWN0IGt2ZWMgKmFyZ3YsIHN0cnVjdCBrdmVjICpyZXN2
KQ0KPiAgICAgICAgIGNsZWFyX2JpdChSUV9EUk9QTUUsICZycXN0cC0+cnFfZmxhZ3MpOw0KPiAg
DQo+ICAgICAgICAgLyogU2V0dXAgcmVwbHkgaGVhZGVyICovDQo+IC0gICAgICAgcnFzdHAtPnJx
X3hwcnQtPnhwdF9vcHMtPnhwb19wcmVwX3JlcGx5X2hkcihycXN0cCk7DQo+ICsgICAgICAgc194
cHJ0LT54cHRfb3BzLT54cG9fcHJlcF9yZXBseV9oZHIocnFzdHApOw0KPiAgDQo+ICAgICAgICAg
c3ZjX3B1dHUzMihyZXN2LCBycXN0cC0+cnFfeGlkKTsNCj4gIA0KPiBAQCAtMTI0NSw3ICsxMjQ1
LDcgQEAgc3ZjX3Byb2Nlc3NfY29tbW9uKHN0cnVjdCBzdmNfcnFzdCAqcnFzdHAsDQo+IHN0cnVj
dCBrdmVjICphcmd2LCBzdHJ1Y3Qga3ZlYyAqcmVzdikNCj4gICAgICAgICAgKiBmaXQuDQo+ICAg
ICAgICAgICovDQo+ICAgICAgICAgaWYgKHZlcnNwLT52c19uZWVkX2NvbmdfY3RybCAmJg0KPiAt
ICAgICAgICAgICAhdGVzdF9iaXQoWFBUX0NPTkdfQ1RSTCwgJnJxc3RwLT5ycV94cHJ0LT54cHRf
ZmxhZ3MpKQ0KPiArICAgICAgICAgICAhdGVzdF9iaXQoWFBUX0NPTkdfQ1RSTCwgJnNfeHBydC0+
eHB0X2ZsYWdzKSkNCg0KDQppZiAodmVyc3AtPnZzX25lZWRfY29uZ19jdHJsICYmIHJxc3RwLT5y
cV94cHJ0ICYmICF0ZXN0X2JpdCguLi4pKSkNCg0KPiANCj4gDQo+IEBAIC0xMzM2LDggKzEzMzYs
OCBAQCBzdmNfcHJvY2Vzc19jb21tb24oc3RydWN0IHN2Y19ycXN0ICpycXN0cCwNCj4gc3RydWN0
IGt2ZWMgKmFyZ3YsIHN0cnVjdCBrdmVjICpyZXN2KQ0KPiAgICAgICAgIHJldHVybiAwOw0KPiAg
DQo+ICAgY2xvc2U6DQo+IC0gICAgICAgaWYgKHRlc3RfYml0KFhQVF9URU1QLCAmcnFzdHAtPnJx
X3hwcnQtPnhwdF9mbGFncykpDQo+IC0gICAgICAgICAgICAgICBzdmNfY2xvc2VfeHBydChycXN0
cC0+cnFfeHBydCk7DQo+ICsgICAgICAgaWYgKHRlc3RfYml0KFhQVF9URU1QLCAmc194cHJ0LT54
cHRfZmxhZ3MpKQ0KPiArICAgICAgICAgICAgICAgc3ZjX2Nsb3NlX3hwcnQoc194cHJ0KTsNCj4g
ICAgICAgICBkcHJpbnRrKCJzdmM6IHN2Y19wcm9jZXNzIGNsb3NlXG4iKTsNCj4gICAgICAgICBy
ZXR1cm4gMDsNCj4gDQo+IA0KPiA+IEl0IHByb2JhYmx5IGFsc28gcmVxdWlyZXMgdXMgdG8gc3Rv
cmUgYSBwb2ludGVyIHRvIHN0cnVjdCBuZXQgaW4NCj4gPiB0aGUNCj4gPiBzdHJ1Y3Qgc3ZjX3Jx
c3Qgc28gdGhhdCBuZnM0X2NhbGxiYWNrX2NvbXBvdW5kKCkgYW5kDQo+ID4gc3ZjYXV0aF9nc3Nf
YWNjZXB0KCkgY2FuIGZpbmQgaXQsIGJ1dCB0aGF0IHNob3VsZCBiZSBPSyBzaW5jZSB0aGUNCj4g
PiB0cmFuc3BvcnQgYWxyZWFkeSBoYXMgdGhhdCByZWZlcmVuY2VkLg0KPiA+IA0KPiA+IENoZWVy
cywNCj4gPiAgIFRyb25kDQo+ID4gDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXIsIEhhbW1lcnNwYWNlDQp0cm9uZC5teWtsZWJ1c3RAaGFtbWVyc3Bh
Y2UuY29tDQoNCg0K
