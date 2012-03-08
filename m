Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:58819 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754781Ab2CHSPn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 13:15:43 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Olga Kornievskaia <aglo@citi.umich.edu>
CC: Miklos Szeredi <miklos@szeredi.hu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 2/2] NFSv4: Return the delegation if the server returns
 NFS4ERR_OPENMODE
Date: Thu, 8 Mar 2012 18:15:26 +0000
Message-ID: <1331230525.2472.39.camel@lade.trondhjem.org>
References: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
	 <1331160049-3842-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1331160049-3842-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1331160049-3842-3-git-send-email-Trond.Myklebust@netapp.com>
	 <CAN-5tyG-w+ie3sxTwNA6e9x=CojxyDaJScJuCbS+9VE=yTmJNA@mail.gmail.com>
In-Reply-To: <CAN-5tyG-w+ie3sxTwNA6e9x=CojxyDaJScJuCbS+9VE=yTmJNA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAzLTA4IGF0IDEyOjUyIC0wNTAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gd291bGRuJ3QgaXQgYmUgYmV0dGVyIGZvciB5b3UgdG8gcHJvYWN0aXZlbHkgcmV0dXJu
IGEgcmVhZCBkZWxlZ2F0aW9uDQo+IHRoZW4gdW5uZWNlc3NhcmlseSBlcnJvcmluZz8NCg0KSWYg
bm9ib2R5IGVsc2UgaG9sZHMgYSBkZWxlZ2F0aW9uLCB0aGVuIHRoZSBORlMgY2xpZW50IGlzIGFj
dHVhbGx5DQphbGxvd2VkIHRvIGtlZXAgaXRzIHJlYWQgZGVsZWdhdGlvbiB3aGlsZSB3cml0aW5n
IHRvIHRoZSBmaWxlLiBJdCBkb2VzDQphZG1pdHRlZGx5IG5lZWQgdG8gcmVxdWVzdCBhbiBPUEVO
IHN0YXRlaWQgZm9yIHdyaXRlIGluIHRoYXQgY2FzZS4uLg0KKFNlZSBzZWN0aW9uIDEwLjQgb2Yg
UkZDMzUzMGJpcyBkcmFmdCAxNikNCg0KVGhhdCBzYWlkLCBpbiBlaXRoZXIgY2FzZSB3ZSBkbyBu
ZWVkIHRvIGRlYWwgd2l0aCB0aGUgZmFjdCB0aGF0IGEgbmV3DQpkZWxlZ2F0aW9uIG1heSBiZSBn
cmFudGVkIGFmdGVyIHdlIHJldHVybiB0aGUgb2xkIG9uZS4gVGhlcmUgaXMgbm8NCmxvY2tpbmcg
YXJvdW5kIHRoZSBzZXRhdHRyIGNhbGwgdG8gcHJldmVudCB0aGlzLg0KDQo+IGkgYWxzbyBkb24n
dCB1bmRlcnN0YW5kIGhvdyB0aGlzIGVycm9yIG9jY3Vycy4gZG9pbmcgYSBzZXRhdHRyIGluIHRo
aXMNCj4gY2FzZSB5b3UgbXVzdCBoYXZlIHVzZWQgYSBub24tc3BlY2lhbCBzdGF0ZWlkLiB0aGUg
c2VydmVyIHdvdWxkIG9ubHkNCj4gcmV0dXJuIGFuIGVycl9vcGVubW9kZSBpZiB5b3Ugc2VudCB0
aGUgc2V0YXR0ciB3aXRoIGEgcmVhZCBkZWxlZ2F0aW9uDQo+IHN0YXRlaWQuIGkgZ3Vlc3MgbXkg
cXVlc3Rpb24gaXMgd2hhdCBzdGF0ZWlkIHdvdWxkIHlvdSB1c2UgdGhhdCBmcm9tDQo+IGNsaWVu
dCdzIHBlcnNwZWN0aXZlIHJlcHJlc2VudCBhIHdyaXRlLXR5cGUgc3RhdGUgaWQgYnV0IHlldCBh
IHNlcnZlcg0KPiB3b3VsZCBmbGFnIGFzIGhhdmluZyB3cm9uZyBhY2Nlc3MgdHlwZT8NCg0KVGhl
IHJlYWQgZGVsZWdhdGlvbiBzdGF0ZWlkIGlzIGJlaW5nIHNlbnQgYXMgcGVyIHRoZSBwcmVzY3Jp
cHRpb24gaW4NCnNlY3Rpb24gOS4xLjMuNiBvZiBSRkMzNTMwYmlzLg0KDQo+IGFsc28gaSdtIGN1
cmlvdXMgd2h5IHdvdWxkIGEgc2VydmVyLCBpbnN0ZWFkIG9mIHJldHVybmluZw0KPiBlcnJfb3Bl
bm1vZGUsIHdvdWxkIG5vdCBmaXJzdCByZWNhbGwgeW91ciByZWFkIGRlbGVnYXRpb24/DQoNCkl0
IGNvdWxkLCBidXQgd2h5IGRvIHNvIHdoZW4gaXQgY2FuIGp1c3QgcmV0dXJuIGFuIGVycm9yIHZh
bHVlPyBUaGUNCnByZXNlbmNlIG9mIHRoZSBkZWxlZ2F0aW9uIHN0YXRlaWQgaW4gdGhlIFNFVEFU
VFIgcmVxdWVzdCBhbGxvd3MgaXQgdG8NCmNvbW11bmljYXRlIGRpcmVjdGx5IHRvIHRoZSBjbGll
bnQgd2hhdCB0aGUgcHJvYmxlbSBpcyB3aXRob3V0IHRoZSBuZWVkDQpmb3IgYW55IGNhbGxiYWNr
cy4NCg0KQ2hlZXJzDQogIFRyb25kDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0K
d3d3Lm5ldGFwcC5jb20NCg0K
