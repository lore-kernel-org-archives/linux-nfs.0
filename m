Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45474 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895Ab2E1DpV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 27 May 2012 23:45:21 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "tao.peng@emc.com" <tao.peng@emc.com>
CC: "bergwolf@gmail.com" <bergwolf@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH 3/3] pnfsblock: bail out unaligned DIO
Date: Mon, 28 May 2012 03:45:19 +0000
Message-ID: <1338176720.2265.8.camel@lade.trondhjem.org>
References: <1338096780-2763-1-git-send-email-bergwolf@gmail.com>
	 <1338096780-2763-4-git-send-email-bergwolf@gmail.com>
	 <1338136717.3044.13.camel@lade.trondhjem.org>
	 <F19688880B763E40B28B2B462677FBF805F0BADF36@MX09A.corp.emc.com>
In-Reply-To: <F19688880B763E40B28B2B462677FBF805F0BADF36@MX09A.corp.emc.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU3VuLCAyMDEyLTA1LTI3IGF0IDIyOjMwIC0wNDAwLCB0YW8ucGVuZ0BlbWMuY29tIHdyb3Rl
Og0KPiBBcyBleHBsYWluIGluIHRoZSBvdGhlciBtYWlsLCBpdCBpcyBuZWNlc3NhcnkgdG8gaGF2
ZSBwbmZzX2Rpb19iZWdpbi9lbmQsIHNvIEkgcHJlZmVyIHRvIGRvIHRoZSB0ZXN0IGFzIGVhcmx5
IGFzIHBvc3NpYmxlLCB3aGljaCBpcyBpbiBwbmZzX2Rpb19iZWdpbi4NCg0KVGhlcmUgaXMgbm8g
cG5mc19kaW9fYmVnaW4vZW5kLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNs
aWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3
dy5uZXRhcHAuY29tDQoNCg==
