Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68EAFC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 15:37:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 011C420880
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 15:37:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="uxtPPjo7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726177AbfBTPhm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 10:37:42 -0500
Received: from mail-eopbgr680107.outbound.protection.outlook.com ([40.107.68.107]:12055
        "EHLO NAM04-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725822AbfBTPhm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 10:37:42 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=hammerspace.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=M6m51wNJyBBpcz8ZORmsvvANhNtjsy10p1SfVRtcpOI=;
 b=uxtPPjo7b4AyqirsHAmMpDyfPW2uPALQYjsh3uuuAfMUlMMXOXONjYXPPS3aJK5+CyyQjdV0VCMhcGV4+m+gld+qKB5p3dWRFyrdz9WIF6/GPTj1duWgUvDKa9G6AgbfI3mGrlXp1QNK1bDzKzcjBI7EQx9ihoFnjMvv37ptW6Y=
Received: from SN6PR13MB2494.namprd13.prod.outlook.com (52.135.95.148) by
 SN6PR13MB2559.namprd13.prod.outlook.com (52.135.96.19) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.7; Wed, 20 Feb 2019 15:37:32 +0000
Received: from SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4]) by SN6PR13MB2494.namprd13.prod.outlook.com
 ([fe80::c1d2:93da:11b5:c4d4%3]) with mapi id 15.20.1643.012; Wed, 20 Feb 2019
 15:37:32 +0000
From:   Trond Myklebust <trondmy@hammerspace.com>
To:     "tibbs@math.uh.edu" <tibbs@math.uh.edu>
CC:     "bcodding@redhat.com" <bcodding@redhat.com>,
        "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Chuck.Lever@oracle.com" <Chuck.Lever@oracle.com>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Thread-Topic: Need help debugging NFS issues new to 4.20 kernel
Thread-Index: AQHUtBBQLoOJiO8U1kuiVnwIPcpCS6W+1kMAgAGQXx+AES4Tb4ABK8OAgACVO9yAAO6cgIAARnn4gAFZDoCAC4+M14ABMVkAgAZUHTSAAANngA==
Date:   Wed, 20 Feb 2019 15:37:31 +0000
Message-ID: <2ab06cbdc19d7a642e04f1e66abbeaa507b034bc.camel@hammerspace.com>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
         <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
         <ufak1isms71.fsf@epithumia.math.uh.edu>
         <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
         <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
         <87imxwab12.fsf@hippogriff.math.uh.edu>
         <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
         <87d0o3aadg.fsf@hippogriff.math.uh.edu>
         <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
         <ufa4l943i6v.fsf@epithumia.math.uh.edu>
         <e8887651e91b1d0110cab2330a03e3e3ccef742b.camel@hammerspace.com>
         <ufapnrmbhyf.fsf@epithumia.math.uh.edu>
In-Reply-To: <ufapnrmbhyf.fsf@epithumia.math.uh.edu>
Accept-Language: en-US, en-GB
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=trondmy@hammerspace.com; 
x-originating-ip: [68.40.189.247]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 9c635ae7-4b7a-4af3-b440-08d69749542b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:SN6PR13MB2559;
x-ms-traffictypediagnostic: SN6PR13MB2559:
x-microsoft-exchange-diagnostics: =?utf-8?B?MTtTTjZQUjEzTUIyNTU5OzIzOnlNcUpYcWxSYVovUTNDMGJiRVhhMmJHcHRD?=
 =?utf-8?B?Qm1hWG1sZ3g5bDk4S094ZkE5L2NvUkpKSDdqbGRGV1RGdFlFaTR4T0pNcU03?=
 =?utf-8?B?amtabWVJcFQvR0RxOEFESmgvV0JFL3Y2aUhjY05TbE51allRYmF4M1Zhakwx?=
 =?utf-8?B?SWhvQWtSbUZick85ODdKZjNxdGkvSzdwM3p3ZDVDaklDTzNHZCtWeXRYL2lI?=
 =?utf-8?B?dVkvVHdnZHF4NHMwNkpoa1lucFVnVHdzS1Mva0R6eEFUOTFLeTh5Zlc1QUJL?=
 =?utf-8?B?RTFXY2hIQm92SDdyMC80SHZwVGU5elA3SWpSVERlTGFISHNiSm00Z3Z0aFcz?=
 =?utf-8?B?eHg0UXZkdUVReDlZRjQvUXJhWWNDM212Mzkvd1ROZXJuVHUwSTdBQUEwbHRB?=
 =?utf-8?B?Nm9rdklTbW94bm9EKys3WmtzM1o0b3Erb0Y1RHpxUmw2KzZIdnZFTzZXaFJw?=
 =?utf-8?B?Y3FYYU1qODRFemdnRmNuRHU1RE90K280UndRYW5ablVkdjNoUllyTXd3UjVM?=
 =?utf-8?B?d0lQakpQMHR6cWQxZ1hDNW9xWkFGRFVNbVUzTVJCRTNEa2k3bmtocXdHQkp5?=
 =?utf-8?B?QjNlSWI5WHltSllIeTRnaWJUdTRldkdjWlU0NTQwYzlmVElkWjF2UVR0dEF5?=
 =?utf-8?B?cFZJTko5RlpLTGZlZ2JSdHlobzRldVhSZEtoV0xQUTllb1hJb2tIS3NTQVcw?=
 =?utf-8?B?TjNZY3ErcHl1VjlpWGlqRkJ2NlZkZlM3MjdqWkdjL3k1L1RnSjVDRVNidFVP?=
 =?utf-8?B?UmFVVkNXNzRPRVg4eXZVU04yK0F1aFFMS1FNSVpNazdwODdXclRTM2lSUGVP?=
 =?utf-8?B?L0EyeHcwMk9nWlRuV3F2UlpUT0NJM3VYSThYYjhzeTR3aFlBekxhUWZzQ0lI?=
 =?utf-8?B?L1k4TFhrMHdTWC92RHVabmlxbkVMTkI3M3lDZDB4MlFzcmUvbCt2VkpGQnNU?=
 =?utf-8?B?SEhJMDBYbVBnZ08vbXdvUTdjUVlPdUluYXA3Umo2bE5wSTFnSTFWalpPbUtT?=
 =?utf-8?B?emJHcVNpZ0FkR1FlRHI5cWl0NExHdk1TUDZtQWFvVlZxeG8vT0JKWFJxMHFD?=
 =?utf-8?B?ZGliam52WEE3Rk1pTUJhdXN1a1VmWUkrTndjSzhYSTljbmx5bVdzOTBuK1lQ?=
 =?utf-8?B?OXAxL29uR1pKdDIvMGdkZFVPb05YTmc4dHU1MjZvTG51N2NNZEY2V3BPbzhJ?=
 =?utf-8?B?OEFHOGREWERvekpEcUs3czM2ZlZ0YXlIQUZCa2hJbmZmZW9GSTh6SEhSUmVZ?=
 =?utf-8?B?WlNONjZBN2pwVEpNenRPMEVSR0pnb2ZrTXRhRnc0Y08vd0VheXB5ZTA5SDNN?=
 =?utf-8?B?K1hIazFrdFl5U2hyYlREQkhBakdTL2xVb1VwSXVLN3R6aG1tNXVmSWZNM2Vy?=
 =?utf-8?B?Z25jQkxkQnpZTm9GSDlZZDdPcFoxSS94QktzWXVuN0w5S25wUThNcS9EbjR6?=
 =?utf-8?B?bVNvV2RIMmllZVp1d0xtc0o3YkpPd0hjYU9ScjFhWU8wYkdKQWtkTCthdGt1?=
 =?utf-8?B?cUJoRzhhQjBINDdyUWZkTWJYWXNYbnFKc3AwS3RuTUo0dm12ZHFienhESTNo?=
 =?utf-8?B?QU1mR1oyZzJjRDdIUnBkcmozVTFlbEtpUFRRN3BYR1BNbk1aV1U4RTAzTHlP?=
 =?utf-8?B?bzdsbzZJTGEyTWVQMFgreTB1MCtuVVN2dmt0VkVrY3BnaWlSckxyU2RERDlw?=
 =?utf-8?B?YUlYUzN3MFFuMUhFK1NCcC9XK014NnBqVXAyRVF5N00zQjF5Njl2NE1aLzRZ?=
 =?utf-8?B?RXBaekdjQjZlVTc5M2I4aVVxOTJHTTZmV1F4TkxLUDFuTjVRdTMwdGJtNlBB?=
 =?utf-8?B?UHRvSkN2d1VoemUyUk1JMFpET0VMM2xzYzlpVUhrbVhueFR3R2hneDRKdkoy?=
 =?utf-8?B?R2JHc05HRUtBUXJiL05vQ1lkVnJ2a3gxSHpaa1lFV29jWW5yeEZ4NnluZ0NB?=
 =?utf-8?Q?bPPqO+nMO2feqstuO9tWIDVbzop9Xc=3D?=
x-microsoft-antispam-prvs: <SN6PR13MB2559ABAC84238BAB3FBCB2B0B87D0@SN6PR13MB2559.namprd13.prod.outlook.com>
x-forefront-prvs: 0954EE4910
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(979002)(346002)(396003)(136003)(39830400003)(376002)(366004)(199004)(189003)(6436002)(5660300002)(93886005)(2171002)(66066001)(2501003)(2616005)(6512007)(6246003)(26005)(478600001)(186003)(446003)(6506007)(11346002)(2906002)(68736007)(71200400001)(76176011)(3846002)(25786009)(54906003)(5640700003)(36756003)(53936002)(486006)(99286004)(86362001)(476003)(71190400001)(6116002)(305945005)(97736004)(7736002)(14454004)(256004)(6486002)(14444005)(1730700003)(106356001)(316002)(2351001)(118296001)(81156014)(4326008)(8676002)(81166006)(8936002)(105586002)(102836004)(229853002)(6916009)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:SN6PR13MB2559;H:SN6PR13MB2494.namprd13.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: hammerspace.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 3ixcFmqUQe7KQREgV5UsthSDRXo9lXrF+Cs+L5DDA4J6nCnsHqaAN87BCvOTy5veVj95bOW88ud708uQhmO/yiNvi+6e0+azZk8gillGSldyag2JpbSqMxZM9PboFwAz6/Q4Lo4vCRhGC0pgfc1pZ8pymdbTBW+1LlHJB4H7CXYgS03pLnp7p6mXSMtWp3bFu3YTSaaSMfHH/mvwz2mpT2o6uLsXZOaEQtzdUbxsqhGFmtxMTubwnOEDIIGMrpjeAC4FymXyEV09eGIfjJynr1o5HXsW1/rUL69c0bpwvZQhhPLi8fZBFzSNB0YPIEU+1wYz8cFUl/QDUD5PGco+nH/GNreEHMZ4PI9hQjqggoZRmX9QbQW2jzdd53KBSPmClDhA1gAnkSpeC+Oidly8DV90wUCpowZACKOxvDpLLbw=
Content-Type: text/plain; charset="utf-8"
Content-ID: <03A0DFFF1B636B40B07AE46227B69EF6@namprd13.prod.outlook.com>
Content-Transfer-Encoding: base64
MIME-Version: 1.0
X-OriginatorOrg: hammerspace.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 9c635ae7-4b7a-4af3-b440-08d69749542b
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Feb 2019 15:37:31.8519
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 0d4fed5c-3a70-46fe-9430-ece41741f59e
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: SN6PR13MB2559
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

T24gV2VkLCAyMDE5LTAyLTIwIGF0IDA5OjI1IC0wNjAwLCBKYXNvbiBMIFRpYmJpdHRzIElJSSB3
cm90ZToNCj4gU2FkbHksIGFmdGVyIGEgYml0IG1vcmUgdGVzdGluZyBJIGZpbmQgdGhhdCA0LjIw
LjEwIHdpdGggdGhhdCBwYXRjaA0KPiBhcHBsaWVkIHN0aWxsIGV4aGliaXRzIHRoZSBwcm9ibGVt
LiAgSnVzdCBmb3VuZCBhIG1hY2hpbmUgd2hlcmUgTkZTDQo+IGh1bmcNCj4gdXAganVzdCBzaXgg
bWludXRlcyBhZnRlciB0aGUgdXNlciBsb2dnZWQgaW4uICBBcyBhbHdheXM6IG5vdGhpbmcgaXMN
Cj4gbG9nZ2VkIHRvIHRoZSBjbGllbnQgb3IgdGhlIHNlcnZlci4gIEkgdHVybmVkIG9uIHRoZSB0
cmFjaW5nIGFzDQo+IHJlcXVlc3RlZCBwcmV2aW91c2x5IGFuZCBzZWUgd2hhdCBJIHRoaW5rIGl0
IGp1c3QgdGhlIHNhbWUgc2VxdWVuY2UNCj4gYXMNCj4gYmVmb3JlLiAgUGxlYXNlIGxldCBtZSBr
bm93IGlmIHRoZXJlIGlzIGFueSBvdGhlciBpbmZvcm1hdGlvbiBJIGNhbg0KPiBwcm92aWRlLiAg
UmlnaHQgbm93IEknbSBnb2luZyB0byBidWlsZCA0LjIwLjEwIHdpdGggbXkgcHJldmlvdXNseQ0K
PiBwb3N0ZWQNCj4gcmV2ZXJ0IHBhdGNoIGFwcGxpZWQgYW5kIHJvbGwgdGhhdCBvdXQgdG8gdGhl
IHNhbWUgNTAgaG9zdHMgYW5kIHNlZQ0KPiBob3cNCj4gaXQgZmFyZXMuDQo+IA0KPiAgLSBKPA0K
PiANCj4gICAgIGt3b3JrZXIvdTg6MC0xMjYwOCBbMDAxXSAuLi4uIDQ3ODg0LjY2MTA3MzogcnBj
X3JlcXVlc3Q6IHRhc2s6DQo+IDIwNDY5QDEgbmZzdjQgU0VRVUVOQ0UgKGFzeW5jKQ0KPiAgICAg
a3dvcmtlci91ODowLTEyNjA4IFswMDFdIC4uLi4gNDc4ODQuNjYxMDczOiBycGNfdGFza19ydW5f
YWN0aW9uOg0KPiB0YXNrOjIwNDY5QDEgZmxhZ3M9NTI4MSBzdGF0ZT0wMDA1IHN0YXR1cz0wIGFj
dGlvbj1jYWxsX3Jlc2VydmUNCj4gW3N1bnJwY10NCj4gICAgIGt3b3JrZXIvdTg6MC0xMjYwOCBb
MDAxXSAuLi4uIDQ3ODg0LjY2MTA3NDogcnBjX3Rhc2tfcnVuX2FjdGlvbjoNCj4gdGFzazoyMDQ2
OUAxIGZsYWdzPTUyODEgc3RhdGU9MDAwNSBzdGF0dXM9MCBhY3Rpb249Y2FsbF9yZXNlcnZlcmVz
dWx0DQo+IFtzdW5ycGNdDQo+ICAgICBrd29ya2VyL3U4OjAtMTI2MDggWzAwMV0gLi4uLiA0Nzg4
NC42NjEwNzQ6IHJwY190YXNrX3J1bl9hY3Rpb246DQo+IHRhc2s6MjA0NjlAMSBmbGFncz01Mjgx
IHN0YXRlPTAwMDUgc3RhdHVzPTAgYWN0aW9uPWNhbGxfcmVmcmVzaA0KPiBbc3VucnBjXQ0KPiAg
ICAga3dvcmtlci91ODowLTEyNjA4IFswMDFdIC4uLi4gNDc4ODQuNjYxMDc1OiBycGNfdGFza19y
dW5fYWN0aW9uOg0KPiB0YXNrOjIwNDY5QDEgZmxhZ3M9NTI4MSBzdGF0ZT0wMDA1IHN0YXR1cz0w
IGFjdGlvbj1jYWxsX3JlZnJlc2hyZXN1bHQNCj4gW3N1bnJwY10NCj4gICAgIGt3b3JrZXIvdTg6
MC0xMjYwOCBbMDAxXSAuLi4uIDQ3ODg0LjY2MTA3NjogcnBjX3Rhc2tfcnVuX2FjdGlvbjoNCj4g
dGFzazoyMDQ2OUAxIGZsYWdzPTUyODEgc3RhdGU9MDAwNSBzdGF0dXM9MCBhY3Rpb249Y2FsbF9h
bGxvY2F0ZQ0KPiBbc3VucnBjXQ0KPiAgICAga3dvcmtlci91ODowLTEyNjA4IFswMDFdIC4uLi4g
NDc4ODQuNjYxMDc2OiBycGNfdGFza19ydW5fYWN0aW9uOg0KPiB0YXNrOjIwNDY5QDEgZmxhZ3M9
NTI4MSBzdGF0ZT0wMDA1IHN0YXR1cz0wIGFjdGlvbj1jYWxsX2VuY29kZQ0KPiBbc3VucnBjXQ0K
PiAgICAga3dvcmtlci91ODowLTEyNjA4IFswMDFdIC4uLi4gNDc4ODQuNjYxMDkxOiBycGNfdGFz
a19ydW5fYWN0aW9uOg0KPiB0YXNrOjIwNDY5QDEgZmxhZ3M9NTI4MSBzdGF0ZT0wMDFkIHN0YXR1
cz0wIGFjdGlvbj1jYWxsX2JpbmQgW3N1bnJwY10NCj4gICAgIGt3b3JrZXIvdTg6MC0xMjYwOCBb
MDAxXSAuLi4uIDQ3ODg0LjY2MTA5MTogcnBjX3Rhc2tfcnVuX2FjdGlvbjoNCj4gdGFzazoyMDQ2
OUAxIGZsYWdzPTUyODEgc3RhdGU9MDAxZCBzdGF0dXM9MCBhY3Rpb249Y2FsbF9jb25uZWN0DQo+
IFtzdW5ycGNdDQo+ICAgICBrd29ya2VyL3U4OjAtMTI2MDggWzAwMV0gLi4uLiA0Nzg4NC42NjEw
OTI6IHJwY190YXNrX3J1bl9hY3Rpb246DQo+IHRhc2s6MjA0NjlAMSBmbGFncz01MjgxIHN0YXRl
PTAwMWQgc3RhdHVzPTAgYWN0aW9uPWNhbGxfdHJhbnNtaXQNCj4gW3N1bnJwY10NCj4gICAgIGt3
b3JrZXIvdTg6MC0xMjYwOCBbMDAxXSAuLi4uIDQ3ODg0LjY2MTEwNjogeHBydF90cmFuc21pdDoN
Cj4gcGVlcj1bMTcyLjIxLjg2Ljc0XToyMDQ5IHhpZD0weDBkN2NhMDY4IHN0YXR1cz0wDQo+ICAg
ICBrd29ya2VyL3U4OjAtMTI2MDggWzAwMV0gLi4uLiA0Nzg4NC42NjExMDc6IHJwY190YXNrX3J1
bl9hY3Rpb246DQo+IHRhc2s6MjA0NjlAMSBmbGFncz01YTgxIHN0YXRlPTAwMTUgc3RhdHVzPTAN
Cj4gYWN0aW9uPWNhbGxfdHJhbnNtaXRfc3RhdHVzIFtzdW5ycGNdDQo+ICAgICBrd29ya2VyL3U4
OjAtMTI2MDggWzAwMV0gLi4uLiA0Nzg4NC42NjExMDc6IHJwY190YXNrX3NsZWVwOiB0YXNrOg0K
PiAyMDQ2OUAxIGZsYWdzPTVhODEgc3RhdGU9MDAxNSBzdGF0dXM9MCB0aW1lb3V0PTYwMDAwDQo+
IHF1ZXVlPXhwcnRfcGVuZGluZw0KPiAgICAga3dvcmtlci91OTowLTEyODg0IFswMDJdIC4uLi4g
NDc4ODQuNjYxMzcxOiB4cHJ0X2xvb2t1cF9ycXN0Og0KPiBwZWVyPVsxNzIuMjEuODYuNzRdOjIw
NDkgeGlkPTB4MGQ3Y2EwNjggc3RhdHVzPTANCj4gICAgIGt3b3JrZXIvdTk6MC0xMjg4NCBbMDAy
XSAuLi4uIDQ3ODg0LjY2MTM3MjogeHBydF9jb21wbGV0ZV9ycXN0Og0KPiBwZWVyPVsxNzIuMjEu
ODYuNzRdOjIwNDkgeGlkPTB4MGQ3Y2EwNjggc3RhdHVzPTExMg0KPiAgICAga3dvcmtlci91OTow
LTEyODg0IFswMDJdIC4uLi4gNDc4ODQuNjYxMzczOiBycGNfdGFza193YWtldXA6DQo+IHRhc2s6
MjA0NjlAMSBmbGFncz01YTgxIHN0YXRlPTAwMDYgc3RhdHVzPTAgdGltZW91dD02MDAwMA0KPiBx
dWV1ZT14cHJ0X3BlbmRpbmcNCj4gICAgIGt3b3JrZXIvdTk6MC0xMjg4NCBbMDAyXSAuLi4uIDQ3
ODg0LjY2MTM3NToNCj4geHNfc3RyZWFtX3JlYWRfcmVxdWVzdDogcGVlcj1bMTcyLjIxLjg2Ljc0
XToyMDQ5IHhpZD0weDBkN2NhMDY4DQo+IGNvcGllZD0xMTIgcmVjbGVuPTExMiBvZmZzZXQ9MTEy
DQo+ICAgICBrd29ya2VyL3U5OjAtMTI4ODQgWzAwMl0gLi4uLiA0Nzg4NC42NjEzNzY6IHhzX3N0
cmVhbV9yZWFkX2RhdGE6DQo+IHBlZXI9WzE3Mi4yMS44Ni43NF06MjA0OSBlcnI9LTExIHRvdGFs
PTExNg0KPiAgICAga3dvcmtlci91ODowLTEyNjA4IFswMDFdIC4uLi4gNDc4ODQuNjYxMzg4OiBy
cGNfdGFza19ydW5fYWN0aW9uOg0KPiB0YXNrOjIwNDY5QDEgZmxhZ3M9NWE4MSBzdGF0ZT0wMDA1
IHN0YXR1cz0wIGFjdGlvbj14cHJ0X3RpbWVyDQo+IFtzdW5ycGNdDQo+ICAgICBrd29ya2VyL3U4
OjAtMTI2MDggWzAwMV0gLi4uLiA0Nzg4NC42NjEzODk6IHJwY190YXNrX3J1bl9hY3Rpb246DQo+
IHRhc2s6MjA0NjlAMSBmbGFncz01YTgxIHN0YXRlPTAwMDUgc3RhdHVzPTAgYWN0aW9uPWNhbGxf
c3RhdHVzDQo+IFtzdW5ycGNdDQo+ICAgICBrd29ya2VyL3U4OjAtMTI2MDggWzAwMV0gLi4uLiA0
Nzg4NC42NjEzODk6IHJwY190YXNrX3J1bl9hY3Rpb246DQo+IHRhc2s6MjA0NjlAMSBmbGFncz01
YTgxIHN0YXRlPTAwMDUgc3RhdHVzPTAgYWN0aW9uPWNhbGxfZGVjb2RlDQo+IFtzdW5ycGNdDQo+
ICAgICBrd29ya2VyL3U4OjAtMTI2MDggWzAwMV0gLi4uLiA0Nzg4NC42NjE0MDg6IHJwY190YXNr
X3J1bl9hY3Rpb246DQo+IHRhc2s6MjA0NjlAMSBmbGFncz01YTgxIHN0YXRlPTAwMDUgc3RhdHVz
PS0xMDA2MyBhY3Rpb249cnBjX2V4aXRfdGFzaw0KPiBbc3VucnBjXQ0KPiAgICAga3dvcmtlci91
ODowLTEyNjA4IFswMDFdIC4uLi4gNDc4ODQuNjYxNDA5OiBuZnM0X3NlcXVlbmNlX2RvbmU6DQo+
IGVycm9yPS0xMDA2MyAoU0VRX01JU09SREVSRUQpIHNlc3Npb249MHg0NDgwZTcyNSBzbG90X25y
PTAgc2VxX25yPTENCj4gaGlnaGVzdF9zbG90aWQ9MCB0YXJnZXRfaGlnaGVzdF9zbG90aWQ9MCBz
dGF0dXNfZmxhZ3M9MCAoKQ0KPiAgICAga3dvcmtlci91ODowLTEyNjA4IFswMDFdIC4uLi4gNDc4
ODQuNjYxNDEwOiBycGNfc3RhdHNfbGF0ZW5jeToNCj4gdGFzazoyMDQ2OUAxIHhpZD0weDBkN2Nh
MDY4IG5mc3Y0IFNFUVVFTkNFIGJhY2tsb2c9MjEgcnR0PTI3OA0KPiBleGVjdXRlPTMzOQ0KPiAg
ICAga3dvcmtlci91ODowLTEyNjA4IFswMDFdIC4uLi4gNDc4ODQuNjYxNDEyOiBycGNfdGFza19y
dW5fYWN0aW9uOg0KPiB0YXNrOjIwNDY5QDEgZmxhZ3M9NTI4MSBzdGF0ZT0wMDA1IHN0YXR1cz0w
IGFjdGlvbj1ycGNfcHJlcGFyZV90YXNrDQo+IFtzdW5ycGNdDQo+ICAgICBrd29ya2VyL3U4OjAt
MTI2MDggWzAwMV0gLi4uLiA0Nzg4NC42NjE0MTM6IG5mczRfc2V0dXBfc2VxdWVuY2U6DQo+IHNl
c3Npb249MHg0NDgwZTcyNSBzbG90X25yPTAgc2VxX25yPTEgaGlnaGVzdF91c2VkX3Nsb3RpZD0w
DQo+ICAgICBrd29ya2VyL3U4OjAtMTI2MDggWzAwMV0gLi4uLiA0Nzg4NC42NjE0MTM6IHJwY190
YXNrX3J1bl9hY3Rpb246DQo+IHRhc2s6MjA0NjlAMSBmbGFncz01MjgxIHN0YXRlPTAwMDUgc3Rh
dHVzPTAgYWN0aW9uPWNhbGxfc3RhcnQNCj4gW3N1bnJwY10NCj4gICAgIGt3b3JrZXIvdTg6MC0x
MjYwOCBbMDAxXSAuLi4uIDQ3ODg0LjY2MTQxNDogcnBjX3JlcXVlc3Q6IHRhc2s6DQo+IDIwNDY5
QDEgbmZzdjQgU0VRVUVOQ0UgKGFzeW5jKQ0KDQpUaGlzIGlzIG5vdCBhbiBSUEMgbGF5ZXIgaXNz
dWUuIEl0IGlzIGEgU0VRX01JU09SREVSRUQgZXJyb3Igb24gc2xvdCAwLg0KSWYgdGhlIGNsaWVu
dCBjYW4ndCByZWNvdmVyIHRoZW4gdGhhdCB3aWxsIGhhbmcgeW91ciBORlN2NC4xIHNlc3Npb24N
CmFnYWluc3QgdGhhdCBzZXJ2ZXIuDQoNCkFyZSB5b3Ugc3VyZSB0aGlzIGlzbid0IHdoYXQgd2Fz
IGhhcHBlbmluZyBwcmV2aW91c2x5Pw0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZT
IGNsaWVudCBtYWludGFpbmVyLCBIYW1tZXJzcGFjZQ0KdHJvbmQubXlrbGVidXN0QGhhbW1lcnNw
YWNlLmNvbQ0KDQoNCg==
