Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7622EC0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 15:22:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1DEED2081B
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 15:22:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="KYShCJ7r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DEED2081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=hammerspace.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728078AbeKBAZp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 20:25:45 -0400
Received: from mail-bl2nam02on0127.outbound.protection.outlook.com ([104.47.38.127]:34784
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727966AbeKBAZp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Nov 2018 20:25:45 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=+HTMz1kC/AUBOwQ4bzyfkxMD73lR35qY+McQNckbx7w=;
 b=KYShCJ7r79toKKZoJSkPNEidSyBB0fHXu9p/fmS8mMtaSfvn3MEeR6YtPbyQmJQzsiboTulImg7DogJOuAz1VfxfxhLFX+NYtMJ/7U2JsgYfrc7dONItxOVtAH+gcw77kpMi1RhGnJ+1TsrvEzogBrUgcdH2jHdNLBMQxlEsB7U=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2573.namprd13.prod.outlook.com (52.135.96.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.9; Thu, 1 Nov 2018 15:22:15 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::205a:69c2:1cf5:b475%3]) with mapi id 15.20.1294.021; Thu, 1 Nov 2018
 15:22:15 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "peterz@infradead.org" <peterz@infradead.org>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linux@roeck-us.net" <linux@roeck-us.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
        "will.deacon@arm.com" <will.deacon@arm.com>,
        "boqun.feng@gmail.com" <boqun.feng@gmail.com>,
        "paul.burton@mips.com" <paul.burton@mips.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "jhogan@kernel.org" <jhogan@kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "paulus@samba.org" <paulus@samba.org>,
        "mpe@ellerman.id.au" <mpe@ellerman.id.au>,
        "benh@kernel.crashing.org" <benh@kernel.crashing.org>
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Thread-Topic: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Thread-Index: AQHUcVNDmGGj0g6AA0y1ofQdOo8K7KU5392AgAAIbYCAABkRAIAADIkAgADaSwCAABwhAIAABl2A
Date:   Thu, 1 Nov 2018 15:22:15 +0000
Message-ID: <f38e272f7a96e983549e4281aa9fd02833a4277a.camel@hammerspace.com>
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
         <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
         <20181031220253.GA15505@roeck-us.net>
         <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
         <4e2438a23d2edf03368950a72ec058d1d299c32e.camel@hammerspace.com>
         <20181101131846.biyilr2msonljmij@lakrids.cambridge.arm.com>
         <20181101145926.GE3178@hirez.programming.kicks-ass.net>
In-Reply-To: <20181101145926.GE3178@hirez.programming.kicks-ass.net>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.195.73]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;SN6PR13MB2573;6:Rk4RVUfzjgqX2GL+cQta5Do25EKpM1M+Fb2+YYmhh15nm+z2DJ+IkyWAJ3ojJkI0i8uETHSm3c0Rp265cL6bb3iiSprTLL51OPQcrXCgti/Sc2in5rCluBIpE0tR+MDhyaD2b1GBiC18D6TnRu/U95vB0gsUic/iB4bSZYYmhYnm+9bZQgqEMuEMd+Y13V+jJwGqPZ2LuC/Pj1FgUZn9WDvMqmoBnJdbxdAOZvit0njMAKcx7AgJ9wdYW+M6qvasYSdAaseHdGXNSL4p5BzJfFAOMaAuDxjRDf0ECq7Mdqm3OODHOzSJhlCwmywuplng+fv9/vrlMEaM8Mx3c5UM5r0egGpfbNPfHuNjoPiZYHmuhq5+IMxqbf0tBJd+UymnjxC2En1QhX3Beg0wib9dBG2zLVYNTQBfcnAA/vT0AyNewBf6cEhb6aIGuejgBCObslLG9ci5ri19Am8C0FJ4xQ==;5:NIkcp0W7IUjozkWMiwox/Zb2hfLq0BOB7vzVGE3OXZZzcDlgwroS53Veyu6lMugusBH505NF/yj/omYHC+/ldZXMd+4gHgr7cleqGHRW87VOyVI+RVFuLRAXZvg/9P/kNkj9H8PvBaAy5mSNKEGrbpCSx9n7+tLvZ/eymNhT8Mc=;7:j1IvOTO0WFQsjD+nO8bJ0+UEUnAnd/opmQnZYAQVjZP5xmEK2Ehzkyt30J0RF96WF+t8AXTYKkT3ZvLuyMbC3zmkuRAIxf/LOlDFCI4dwXHUOeTZdi0POEwyAHpSTUZGpuEgptLIjNX39KA0/M6bRA==
x-ms-office365-filtering-correlation-id: 558072f1-34bf-4717-3741-08d6400dce2a
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2573;
x-ms-traffictypediagnostic: SN6PR13MB2573:
x-microsoft-antispam-prvs: <SN6PR13MB2573CC5572C6ABC0F239B231B8CE0@SN6PR13MB2573.namprd13.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(10201501046)(3002001)(93006095)(93001095)(3231382)(944501410)(52105095)(148016)(149066)(150057)(6041310)(201703131423095)(201702281528075)(20161123555045)(201703061421075)(201703061406153)(20161123564045)(20161123558120)(20161123562045)(20161123560045)(201708071742011)(7699051)(76991095);SRVR:SN6PR13MB2573;BCL:0;PCL:0;RULEID:;SRVR:SN6PR13MB2573;
x-forefront-prvs: 0843C17679
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(136003)(376002)(39830400003)(396003)(366004)(199004)(189003)(66066001)(105586002)(54906003)(186003)(71190400001)(6506007)(118296001)(3846002)(71200400001)(5660300001)(2906002)(93886005)(26005)(6246003)(110136005)(97736004)(7736002)(316002)(14444005)(14454004)(305945005)(4326008)(99286004)(81166006)(476003)(229853002)(11346002)(5250100002)(478600001)(106356001)(53936002)(2616005)(25786009)(81156014)(39060400002)(446003)(102836004)(36756003)(86362001)(2900100001)(6436002)(68736007)(6512007)(8676002)(76176011)(486006)(8936002)(256004)(6486002)(2501003)(7416002)(6116002)(41533002);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2573;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: UZva/TZFEqKdC0/GNpvw+Q8UEOCvgmJnyrDsube8vhbP/INGW5eJkrI8Kw1TUM4gox/E/vI25Pj2ifdNZxhVWGEPbDf14x2M1bHXDw/3cvzkmtzHx81zQv4slo4TekuuilifqLbixV42EixZXSTPPrrkujShq1vrZAaaEMA9mgAcl6dmF8hIe1hN7GN7F8V+hmsCC4/4tHqT0jDaZtCZtDpAZKXOrgfAS655PRL2/JGGqt2/4opGIUikMS4w7LEQm+ddJyYoQYCs4YP7BqJBFcmaC4BHIbg3TgHD1lZykibkaE0w+M1s2VUueU3SSBVPBogNYhlTsVp3gvNW3QPn8ec2Fhlnwek3ubRmxa2y90M=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="utf-8"
Content-ID: <7988A21B77C49C45BD585BB19AFF3ABD@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 558072f1-34bf-4717-3741-08d6400dce2a
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Nov 2018 15:22:15.3957
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2573
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gVGh1LCAyMDE4LTExLTAxIGF0IDE1OjU5ICswMTAwLCBQZXRlciBaaWpsc3RyYSB3cm90ZToN
Cj4gT24gVGh1LCBOb3YgMDEsIDIwMTggYXQgMDE6MTg6NDZQTSArMDAwMCwgTWFyayBSdXRsYW5k
IHdyb3RlOg0KPiA+ID4gTXkgb25lIHF1ZXN0aW9uIChhbmQgdGhlIHJlYXNvbiB3aHkgSSB3ZW50
IHdpdGggY21weGNoZygpIGluIHRoZQ0KPiA+ID4gZmlyc3QNCj4gPiA+IHBsYWNlKSB3b3VsZCBi
ZSBhYm91dCB0aGUgb3ZlcmZsb3cgYmVoYXZpb3VyIGZvcg0KPiA+ID4gYXRvbWljX2ZldGNoX2lu
YygpIGFuZA0KPiA+ID4gZnJpZW5kcy4gSSBiZWxpZXZlIHRob3NlIGZ1bmN0aW9ucyBzaG91bGQg
YmUgT0sgb24geDg2LCBzbyB0aGF0DQo+ID4gPiB3aGVuIHdlDQo+ID4gPiBvdmVyZmxvdyB0aGUg
Y291bnRlciwgaXQgYmVoYXZlcyBsaWtlIGFuIHVuc2lnbmVkIHZhbHVlIGFuZCB3cmFwcw0KPiA+
ID4gYmFjaw0KPiA+ID4gYXJvdW5kLiAgSXMgdGhhdCB0aGUgY2FzZSBmb3IgYWxsIGFyY2hpdGVj
dHVyZXM/DQo+ID4gPiANCj4gPiA+IGkuZS4gYXJlIGF0b21pY190L2F0b21pYzY0X3QgYWx3YXlz
IGd1YXJhbnRlZWQgdG8gYmVoYXZlIGxpa2UNCj4gPiA+IHUzMi91NjQNCj4gPiA+IG9uIGluY3Jl
bWVudD8NCj4gPiA+IA0KPiA+ID4gSSBjb3VsZCBub3QgZmluZCBhbnkgZG9jdW1lbnRhdGlvbiB0
aGF0IGV4cGxpY2l0bHkgc3RhdGVkIHRoYXQNCj4gPiA+IHRoZXkNCj4gPiA+IHNob3VsZC4NCj4g
PiANCj4gPiBQZXRlciwgV2lsbCwgSSB1bmRlcnN0YW5kIHRoYXQgdGhlIGF0b21pY190L2F0b21p
YzY0X3Qgb3BzIGFyZQ0KPiA+IHJlcXVpcmVkDQo+ID4gdG8gd3JhcCBwZXIgMidzLWNvbXBsZW1l
bnQuIElJVUMgdGhlIHJlZmNvdW50IGNvZGUgcmVsaWVzIG9uIHRoaXMuDQo+ID4gDQo+ID4gQ2Fu
IHlvdSBjb25maXJtPw0KPiANCj4gVGhlcmUgaXMgcXVpdGUgYSBiaXQgb2YgY29yZSBjb2RlIHRo
YXQgaGFyZCBhc3N1bWVzIDJzLWNvbXBsZW1lbnQuDQo+IE5vdA0KPiBvbmx5IGZvciBhdG9taWNz
IGJ1dCBmb3IgYW55IHNpZ25lZCBpbnRlZ2VyIHR5cGUuIEFsc28gc2VlIHRoZSBrZXJuZWwNCj4g
dXNpbmcgLWZuby1zdHJpY3Qtb3ZlcmZsb3cgd2hpY2ggaW1wbGllcyAtZndyYXB2LCB3aGljaCBk
ZWZpbmVzDQo+IHNpZ25lZA0KPiBvdmVyZmxvdyB0byBiZWhhdmUgbGlrZSAycy1jb21wbGVtZW50
IChhbmQgcmlkcyB1cyBvZiB0aGF0IHBhcnRpY3VsYXINCj4gVUIpLg0KDQpGYWlyIGVub3VnaCwg
YnV0IHRoZXJlIGhhdmUgYWxzbyBiZWVuIGJ1Z2ZpeGVzIHRvIGV4cGxpY2l0bHkgZml4IHVuc2Fm
ZQ0KQyBzdGFuZGFyZHMgYXNzdW1wdGlvbnMgZm9yIHNpZ25lZCBpbnRlZ2Vycy4gU2VlLCBmb3Ig
aW5zdGFuY2UgY29tbWl0DQo1YTU4MWIzNjdiNWQgImppZmZpZXM6IEF2b2lkIHVuZGVmaW5lZCBi
ZWhhdmlvciBmcm9tIHNpZ25lZCBvdmVyZmxvdyINCmZyb20gUGF1bCBNY0tlbm5leS4NCg0KQW55
aG93LCBpZiB0aGUgYXRvbWljIG1haW50YWluZXJzIGFyZSB3aWxsaW5nIHRvIHN0YW5kIHVwIGFu
ZCBzdGF0ZSBmb3INCnRoZSByZWNvcmQgdGhhdCB0aGUgYXRvbWljIGNvdW50ZXJzIGFyZSBndWFy
YW50ZWVkIHRvIHdyYXAgbW9kdWxvIDJebg0KanVzdCBsaWtlIHVuc2lnbmVkIGludGVnZXJzLCB0
aGVuIEknbSBoYXBweSB0byB0YWtlIFBhdWwncyBwYXRjaC4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1
c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lciwgSGFtbWVyc3BhY2UNCnRyb25kLm15a2xl
YnVzdEBoYW1tZXJzcGFjZS5jb20NCg0KDQo=
