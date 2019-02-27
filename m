Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AF25C4360F
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 01:12:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0F848218D3
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 01:12:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="M84qzdqF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729108AbfB0BMU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Feb 2019 20:12:20 -0500
Received: from mail-eopbgr820118.outbound.protection.outlook.com ([40.107.82.118]:22863
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729035AbfB0BMU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Feb 2019 20:12:20 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cTpHYxemYjKq/1iMw1tQRPKPLMJkiBs04PeJuuDBMFE=;
 b=M84qzdqFcY7ZcLD/tGmL21p9/hliY/i82D21vPsatXyKisyMt3Nwgcr9OVfETilL+CAK8F6KECMWtBO85QmQh+cDd3LF+a4IoCtzpY4CbQs3uCEtzb0QZAXRc5gkT8gA27JHnTCmJENJbIYragUIzQXJVkNG2+1G1CIliBfnqcU=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2381.namprd13.prod.outlook.com (52.135.94.149) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1665.9; Wed, 27 Feb 2019 01:12:15 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%4]) with mapi id 15.20.1665.012; Wed, 27 Feb 2019
 01:12:15 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "davenoveck@gmail.com" <davenoveck@gmail.com>,
        "tigran.mkrtchyan@desy.de" <tigran.mkrtchyan@desy.de>,
        "rmacklem@uoguelph.ca" <rmacklem@uoguelph.ca>
CC:     "devel@lists.nfs-ganesha.org" <devel@lists.nfs-ganesha.org>,
        "linux-nfs-owner@vger.kernel.org" <linux-nfs-owner@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "nfsv4@ietf.org" <nfsv4@ietf.org>
Subject: Re: [nfsv4] file size and getattr
Thread-Topic: [nfsv4] file size and getattr
Thread-Index: xAHUywXrcRtlAwSKakyZeT3C7wTpA6XxZwkAgAAIQwCAAJ3JAIAAv0QAgAAQiYA=
Date:   Wed, 27 Feb 2019 01:12:14 +0000
Message-ID: <9bae6a43ea26f112e015b7b0b213fb9dd43bac68.camel@hammerspace.com>
References: <155049372736.14318.3390584694682770373.idtracker@ietfa.amsl.com>
         <CADaq8je2Ap4oAZAPOguaWctUs8dQ=Q9g=TO39EOiJW5EJSFTGg@mail.gmail.com>
         <OFE5A6CD32.4DC48078-ON882583A9.007FB4BC-882583A9.0080ACAC@notes.na.collabserv.com>
         <CADaq8jfT=nxmVPz4mDRFAaOx36uxWqKbxitqS-YH3GCOs4CsrQ@mail.gmail.com>           ,
 <741516773.7109032.1551084577150.JavaMail.zimbra@desy.de>
         ,<QB1PR01MB3537C4C84605F9C26050DDA8DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
         <QB1PR01MB3537215D010370E139D70843DD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
        ,<1cbdd04ce23c5012f59b6d5dcbb6b505be0675b9.camel@hammerspace.com>
         <QB1PR01MB3537841A7F121CFA082B778ADD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
In-Reply-To: <QB1PR01MB3537841A7F121CFA082B778ADD7B0@QB1PR01MB3537.CANPRD01.PROD.OUTLOOK.COM>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 520ce4bd-7434-456b-ac04-08d69c509c34
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2381;
x-ms-traffictypediagnostic: SN6PR13MB2381:
x-ms-exchange-purlcount: 1
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyMzgxOzIzOjk3UU9GT2pzUCtGbEVpWWlPUXkwZzBVV053?=
 =?utf-8?B?OHNabjduVG9zOE5MNUx5T0J5YTNpVVpIbGc3TGdMM0hjbFVjNlNoUXhncjBP?=
 =?utf-8?B?V3J6akZkd2YxcTdWZFU4TkdBK3p4SHNodjc1elFSbEpEZ2lsVWV4cUd5QmdW?=
 =?utf-8?B?Smg1OXhPYVNvckFJMnJIbDlYdlhXM2crZDNmd0h0VVVQVk9LVHVjaVVXUXdz?=
 =?utf-8?B?cWpMYkw2ZjF6REszVU9pWEpibUgyREZJR1lxcGtrcE1QSmh6UVF0b2MwZ25D?=
 =?utf-8?B?T242emNDRFYybno1R1NqVm9vczlQaldIY1Y2NHl5SVFtWHU0cGFGZkpkN1Bk?=
 =?utf-8?B?NCtTUkxNempyd2J3aTJWcmJnMDNUaWtuN2kxaE1YZlR0L2pjaXJpempPbGpT?=
 =?utf-8?B?WjBSRkorMSsrakdXMjQ5ZVBRK3I1OW1Cd0hlSGhaaXJpWnlRUjBFVkF2V2Za?=
 =?utf-8?B?cjJnZVNXdHNpSUgzVHBiS1F3NmFLSXpkRWFiYmxnVnQ4Y2tLdGhWaXVub2Jh?=
 =?utf-8?B?SlN1cHNRZk1aMXhrN1czVFVQNmRoay8zY2todE1Dd1VTb2hTZ3BZWk9OTEhl?=
 =?utf-8?B?WlFqNFg1RnprdmhVYnJmaVQwdGNET2YxZWcrRHlicEw3K3ZoQkEwOUUxR2o5?=
 =?utf-8?B?bXlMZE9KdWh0MlQ2Zi9kclNSMnM5bkI3cTVmbmhTQmNzRHlOek85MGlRV2tG?=
 =?utf-8?B?bXZzOWxsYkxISEZIY2lnVDBVZ3oxcTgzYXE3R2dZd3ZYYm9iV3g5RFN5cXQ5?=
 =?utf-8?B?UjBBa0tlbVdURzExSi9mVzl3WlRpSDJwaHFCQ0xXUkhvV0FDdHE1cjQ5a0NL?=
 =?utf-8?B?a3NSVGY0QVRFZnc2dDFCNTlleGN4M0Z2WVUrbm9CZnlmczJvbDdab1BpZ2xp?=
 =?utf-8?B?Q1BhTmViTHBlTjVIMHI2bnRWb1NHcXIzZUw4blVYdDdVMnlnQ2RiRXVjTTQr?=
 =?utf-8?B?bTQxQUdRWENFeHUyRXE3MmtsUkcwWnlxYnNFNnlBZ05TL1luZ2I5cXR0c1pT?=
 =?utf-8?B?UlAzbUljWko5a3EwV2pna09oYXZvaWl1N1ZaWXdTVVNmYjUrSnZLejVKMkNt?=
 =?utf-8?B?bEpzbVN5L2NCaTRQc0FlSjV4NldUZk9PdVpZVytIR2NQbWxsK1MxRjBXU2Ro?=
 =?utf-8?B?eEtZb3QxbGhzVFdWaTNoVE51bzlhRFg1U0N1VFhZMWo3TmxmdXZVY3ZiZzl5?=
 =?utf-8?B?UlRMUzdMVzRvYms3U0l0S1ZmcmVCUCtGQWNrR0t0c3BlSDhIOGZDRWIrSUxv?=
 =?utf-8?B?T014SGlrdkUrb1lKWmwrZ1ZYaG9KazJzWWlLQzUvOW5ZTGoxWlV4bUdsZC92?=
 =?utf-8?B?Q24ra1pGWXN6MWZIc0hRem4rdXVNNDJuR0draXA3RmFZOXJmbU9qRGpzSEFK?=
 =?utf-8?B?TFZWTVVQVlJCMWZWcXJZcERqZ1lBVUJlbE9TWmpmd1JwYloyVXdyY0djRW1y?=
 =?utf-8?B?cVdSV3A2MnlZOUdZVjk0WVhMWVVvWEE5clB6L2t2VFg4SjFkWEtUNFJZMUFR?=
 =?utf-8?B?SW5KM1NJRGZ1WEdrNWtnckdBS3NnNytvc2FCSWN5MUdFWitvM3pyaHdPbDFE?=
 =?utf-8?B?Q0xzRE1QL3BKaUl0Q1lnZ2pvOXA2Y0kyKzB2RVFnWEV1WFBTZzZGamFxbDRQ?=
 =?utf-8?B?NUxOUVdEWDEzTDZOYnNQOUNWelBEZXhDUGNqeWc5S0pVU0FtaFJvQmhxMldr?=
 =?utf-8?B?dDVIOE1ORGExQmxxL0ZSbEtWci9iNFZ3MXJ6WWI3RllLTEtNQXd5am9HcUtS?=
 =?utf-8?Q?XtrvT0U4pjwrIp4EX9nwO1DHDFABZoL5PNj+M=3D?=
x-microsoft-antispam-prvs: <SN6PR13MB2381F3A67868E0CDDA25E0F1B8740@SN6PR13MB2381.namprd13.prod.outlook.com>
x-forefront-prvs: 0961DF5286
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(366004)(376002)(136003)(39830400003)(396003)(199004)(189003)(97736004)(6346003)(66066001)(26005)(486006)(6506007)(6246003)(11346002)(476003)(2616005)(76176011)(446003)(99286004)(102836004)(186003)(2501003)(93886005)(53936002)(81166006)(81156014)(256004)(14444005)(8936002)(68736007)(8676002)(2906002)(86362001)(106356001)(6116002)(3846002)(71200400001)(54906003)(229853002)(2201001)(6512007)(25786009)(110136005)(105586002)(478600001)(36756003)(6436002)(6486002)(316002)(305945005)(5660300002)(118296001)(4326008)(71190400001)(966005)(6306002)(14454004)(7736002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2381;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: fxC+L8HXWxPzabk+EzeobmbVyVEkK2EnOgHQQLS+GmReJgRmoMqaPQTUeofpjitLqWALVZixmioOosVX53ix/YmJY0QPesJ7BvMt49AZCLmcY/7WduAPU4e2lfjzQFog6F12RbCQIp+89JUsfnn7V7bfyAsmVa1tAh4weS4J792u7oIGSgKoDAVXr9F8rg+f5Kf4CQyLBh6FCw5TLi49txyTmzWoWxezrvzivadhcxL7CXPMuljTSPD06Mw7qkEUrAA3HXFTwBxDMVI+RQRDnQPCo8Tw1qZh7bO30g8+PNskJhhhs2Ml2mrRNIj5jE3wWnYHaMVx9i2txIkbgAEqVzG3C2oXVGAXQBf5u9jTGgcGYF/IB1J1SUr4dFfhWyXywfRFmRc9CLKr0OEOPDidn8hIev9SO7jiSvyw9XI2AWs=
Content-Type: text/plain; charset="utf-8"
Content-ID: <086F5447B85B2640BCA00D0848AB5D38@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 520ce4bd-7434-456b-ac04-08d69c509c34
X-MS-Exchange-CrossTenant-originalarrivaltime: 27 Feb 2019 01:12:15.0317
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2381
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAyLTI3IGF0IDAwOjEzICswMDAwLCBSaWNrIE1hY2tsZW0gd3JvdGU6DQo+
IFRyb25kIE15a2xlYnVzdCB3cm90ZToNCj4gW3N0dWZmIHNuaXBwZWRdDQo+ID4gUGxlYXNlIHNl
ZSB0aGUgRXJyYXRhIElEIDI3NTEgDQo+ID4gaHR0cDovL3d3dy5yZmMtZWRpdG9yLm9yZy9lcnJh
dGEvZWlkMjc1MQ0KPiANCj4gSSdsbCBhZG1pdCBJIGhhZG4ndCBzZWVuIHRoaXMgZXJyYXRhIGJl
Zm9yZS4gSG93ZXZlciwgaXQgc2VlbXMgdG8gYmUNCj4gc3BlY2lmaWMgdG8NCj4gdGhlIEZpbGUg
TGF5b3V0LiBGb3IgdGhlIEZsZXhpYmxlIEZpbGUgTGF5b3V0Li4uDQo+IA0KPiBXaGVuIEkgbG9v
ayBpbiBSRkMtODQzNSwgSSBjYW5ub3QgZmluZCBhbnl0aGluZyB0aGF0IHN0YXRlcyB0aGF0IGEN
Cj4gTGF5b3V0Q29tbWl0DQo+IGlzIG9ubHkgcmVxdWlyZWQgZm9yIGNhc2Uocykgd2hlcmUgYSBD
b21taXQgdG8gdGhlIFN0b3JhZ2UgU2VydmVyIGlzDQo+IHJlcXVpcmVkLg0KPiBTZWMuIDIuMQ0K
PiAgICBDbGVhcmx5IHN0YXRlcyB0aGF0IGEgQ29tbWl0IHRvIHRoZSBTdG9yYWdlIFNlcnZlciBp
cyByZXF1aXJlZA0KPiBiZWZvcmUgdGhlIGNsaWVudA0KPiAgICBkb2VzIGEgTGF5b3V0Q29tbWl0
IHdoZW4gdGhlIHdyaXRlKHMpIHdlcmUgbm90IGRvbmUgRklMRV9TWU5DLg0KPiAgICBIb3dldmVy
LCBJIGRvIG5vdCBzZWUgYW55IGluZGljYXRpb24gdGhhdCB0aGUgTGF5b3V0Q29tbWl0IGlzIG5v
dA0KPiB0byBiZSBkb25lDQo+ICAgIGZvciB0aGUgY2FzZSB3aGVyZSB0aGUgd3JpdGUocykgYXJl
IGRvbmUgRklMRV9TWU5DLg0KPiANCj4gRkZfRkxBR1NfTk9fTEFZT1VUQ09NTUlUIGNhbiBiZSB1
c2VkIHRvIGluZGljYXRlIHRvIGEgY2xpZW50IHRoYXQNCj4gTGF5b3V0Q29tbWl0cyBhcmUgbm90
IHJlcXVpcmVkLCBidXQgdGhpcyBkb2VzIG5vdCBiZSBkZXBlbmRlbnQgb24gaG93DQo+IHRoZSB3
cml0ZShzKSB0byB0aGUgU3RvcmFnZSBTZXJ2ZXIgd2VyZSBkb25lLg0KPiANCj4gVGhlIG9ubHkg
d2F5IGEgRmxleGlibGUgRmlsZSBsYXlvdXQgTWV0YWRhdGEgc2VydmVyIGNhbiBrbm93IHdoYXQg
dGhlDQo+IGN1cnJlbnQgZmlsZSBzaXplIGlzICh3aGVuIGEgcmVhZC93cml0ZSBsYXlvdXQgaXMg
aXNzdWVkIHRvIGEgY2xpZW50KQ0KPiBpcyB0byBkbyBhDQo+IEdldGF0dHIgdG8gdGhlIFN0b3Jh
Z2UgU2VydmVyLg0KPiBJZiBhIGNsaWVudCBpcyBub3QgcmVxdWlyZWQgdG8gZG8gYSBMYXlvdXRD
b21taXQgd2hlbiB0aGUgd3JpdGUocykgdG8NCj4gdGhlDQo+IFN0b3JhZ2UgU2VydmVyIGFyZSBk
b25lIEZJTEVfU1lOQywgdGhlbiB0aGUgTWV0YWRhdGEgc2VydmVyIG11c3QgZG8NCj4gR2V0YXR0
ciBSUENzIHRvIHRoZSBTdG9yYWdlIFNlcnZlciB3aGVuZXZlciBpdCBuZWVkcyBhbiB1cCB0byBk
YXRlDQo+IGZpbGUgc2l6ZQ0KPiBpZiBhIHJlYWQvd3JpdGUgbGF5b3V0IGlzIGlzc3VlZCB0byBh
IGNsaWVudC4NCj4gDQo+IFRoaXMgY2FuIHJlc3VsdCBpbiBhIGxvdCBvZiBvdmVyaGVhZCB0aGF0
IGNhbiBiZSBhdm9pZGVkIGJ5IHJlcXVpcmluZw0KPiB0aGUNCj4gTGF5b3V0Q29tbWl0IHRvIGJl
IGRvbmUgYnkgYSBjbGllbnQgYWZ0ZXIgd3JpdGluZyB0byBhIFN0b3JhZ2UNCj4gU2VydmVyLA0K
PiBpcnJlc3BlY3RpdmUgb2YgdGhlIG5lZWQgZm9yIGEgQ29tbWl0IHRvIHRoZSBTdG9yYWdlIFNl
cnZlci4NCj4gQXMgc3VjaCwgSSB3b3VsZCByYXRoZXIgbm90IGhhdmUgdGhpcyBlcnJhdGEgYXBw
bGllZCB0byBSRkMtODQzNS4NCj4gDQoNCkZhaXIgZW5vdWdoLiBJIGFncmVlIHRoYXQgdGhlIGVy
cmF0YSBpbiBxdWVzdGlvbiBvbmx5IGFwcGxpZXMgdG8gdGhlDQpwTkZTIGZpbGVzIGxheW91dCwg
aG93ZXZlciB5b3Ugd2VyZSB0YWxraW5nIGFib3V0IFJGQzU2NjEgYW5kIHdoZXRoZXINCm9yIG5v
dCB3ZSB3ZXJlIGludGVycHJldGluZyB0aGF0IGNvcnJlY3RseS4gU2luY2UgUkZDNTY2MSBvbmx5
IHJlZmVycw0KdG8gYWJvdXQgdGhlIGJlaGF2aW91ciBvZiB0aGUgcE5GUyBmaWxlcyBsYXlvdXQs
IHRoZW4gSSBhc3N1bWVkIHRoYXQNCndhcyB3aGF0IHlvdSB3ZXJlIHJlZmVycmluZyB0by4NCg0K
Rm9yIGZsZXhmaWxlcyB3ZSBtYXkgaGF2ZSBhIGJ1ZyBpbiB0aGUgbGF5b3V0Y29tbWl0IGNhc2Uu
IEhvd2V2ZXIgbm90ZQ0KdGhhdCB0aGUgY291bnRlciBhcmd1bWVudCB0byB3aGF0IHlvdSBzdGF0
ZSBhYm92ZSBpcyB0aGF0IF9pZl8gdGhlDQpzZXJ2ZXIgcmVxdWlyZXMgYSBsYXlvdXRjb21taXQg
YmVmb3JlIGl0IHdpbGwgYWNrbm93bGVkZ2UgYSBmaWxlIHNpemUNCmNoYW5nZSwgdGhlbiBwTkZT
IGlzIGxpa2VseSB0byB1bmRlcnBlcmZvcm0gZm9yIGFwcGxpY2F0aW9ucyBzdWNoIGFzDQpkYXRh
YmFzZXMgb3IgVk1zIHdoZXJlIGVhY2ggcmVjb3JkIGlzIHJlcXVpcmVkIHRvIGJlIHdyaXR0ZW4g
aW4gc3RhYmxlDQptb2RlLg0KSU9XOiBJZiBhbGwgd3JpdGVzIHRoYXQgbmVlZCB0byBiZSBzdGFi
bGUgYXJlIGFsc28gcmVxdWlyZWQgdG8gYmUNCmFja25vd2xlZGdlZCB3aXRoIGEgbGF5b3V0Y29t
bWl0ICh0byB0aGUgTURTKSwgdGhlbiB5b3VyIGFiaWxpdHkgdG8NCnNjYWxlIG91dCB5b3VyIHNl
cnZlciB3aWxsIGJlIGluIGRvdWJ0Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNw
YWNlLmNvbQ0KDQoNCg==
