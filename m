Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31295 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756878Ab2DIQRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Apr 2012 12:17:43 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: Grace period
Date: Mon, 9 Apr 2012 16:17:06 +0000
Message-ID: <1333988226.2688.76.camel@lade.trondhjem.org>
References: <4F7F230A.6080506@parallels.com>
	 <20120406234039.GA20940@fieldses.org> <4F82C6E3.3030009@parallels.com>
	 <20120409094743.56932677@tlielax.poochiereds.net>
	 <4F82F16C.7030303@parallels.com>
	 <20120409112739.6a823d6f@corrin.poochiereds.net>
	 <4F830999.5000504@parallels.com> <20120409161114.GB6482@fieldses.org>
In-Reply-To: <20120409161114.GB6482@fieldses.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTA0LTA5IGF0IDEyOjExIC0wNDAwLCBiZmllbGRzQGZpZWxkc2VzLm9yZyB3
cm90ZToNCj4gT24gTW9uLCBBcHIgMDksIDIwMTIgYXQgMDg6MDg6NTdQTSArMDQwMCwgU3Rhbmlz
bGF2IEtpbnNidXJza3kgd3JvdGU6DQo+ID4gMDkuMDQuMjAxMiAxOToyNywgSmVmZiBMYXl0b24g
0L/QuNGI0LXRgjoNCj4gPiA+DQo+ID4gPklmIHlvdSBhbGxvdyBvbmUgY29udGFpbmVyIHRvIGhh
bmQgb3V0IGNvbmZsaWN0aW5nIGxvY2tzIHdoaWxlIGFub3RoZXINCj4gPiA+Y29udGFpbmVyIGlz
IGFsbG93aW5nIHJlY2xhaW1zLCB0aGVuIHlvdSBjYW4gZW5kIHVwIHdpdGggc29tZSB2ZXJ5DQo+
ID4gPmRpZmZpY3VsdCB0byBkZWJ1ZyBzaWxlbnQgZGF0YSBjb3JydXB0aW9uLiBUaGF0J3MgdGhl
IHdvcnN0IHBvc3NpYmxlDQo+ID4gPm91dGNvbWUsIElNTy4gV2UgcmVhbGx5IG5lZWQgdG8gYWN0
aXZlbHkga2VlcCBwZW9wbGUgZnJvbSBzaG9vdGluZw0KPiA+ID50aGVtc2VsdmVzIGluIHRoZSBm
b290IGhlcmUuDQo+ID4gPg0KPiA+ID5PbmUgcG9zc2liaWxpdHkgbWlnaHQgYmUgdG8gb25seSBh
bGxvdyBmaWxlc3lzdGVtcyB0byBiZSBleHBvcnRlZCBmcm9tDQo+ID4gPmEgc2luZ2xlIGNvbnRh
aW5lciBhdCBhIHRpbWUgKGFuZCBhbGxvdyB0aGF0IHRvIGJlIG92ZXJyaWRhYmxlIHNvbWVob3cN
Cj4gPiA+b25jZSB3ZSBoYXZlIGEgd29ya2luZyBhY3RpdmUvYWN0aXZlIHNlcnZpbmcgc29sdXRp
b24pLiBXaXRoIHRoYXQsIHlvdQ0KPiA+ID5tYXkgYmUgYWJsZSBsaW1wIGFsb25nIHdpdGggYSBw
ZXItY29udGFpbmVyIGdyYWNlIHBlcmlvZCBoYW5kbGluZw0KPiA+ID5zY2hlbWUgbGlrZSB5b3Un
cmUgcHJvcG9zaW5nLg0KPiA+ID4NCj4gPiANCj4gPiBPayB0aGVuLiBLZWVwaW5nIHBlb3BsZSBm
cm9tIHNob290aW5nIHRoZW1zZWx2ZXMgaGVyZSBzb3VuZHMgcmVhc29uYWJsZS4NCj4gPiBBbmQg
SSBsaWtlIHRoZSBpZGVhIG9mIGV4cG9ydGluZyBhIGZpbGVzeXN0ZW0gb25seSBmcm9tIG9uY2Ug
cGVyDQo+ID4gbmV0d29yayBuYW1lc3BhY2UuDQo+IA0KPiBVbmZvcnR1bmF0ZWx5IHRoYXQncyBu
b3QgZ29pbmcgdG8gZ2V0IHVzIHZlcnkgZmFyLCBlc3BlY2lhbGx5IG5vdCBpbiB0aGUNCj4gdjQg
Y2FzZSB3aGVyZSB3ZSd2ZSBnb3QgdGhlIGNvbW1vbiByZWFkLW9ubHkgcHNldWRvcm9vdCB0aGF0
IGV2ZXJ5b25lDQo+IGhhcyB0byBzaGFyZS4NCg0KSSBkb24ndCBzZWUgaG93IHRoYXQgY2FuIHdv
cmsgaW4gY2FzZXMgd2hlcmUgZWFjaCBjb250YWluZXIgaGFzIGl0cyBvd24NCnByaXZhdGUgbW91
bnQgbmFtZXNwYWNlLiBZb3UncmUgZ29pbmcgdG8gaGF2ZSB0byB0aWUgdGhhdCBwc2V1ZG9yb290
IHRvDQp0aGUgbW91bnQgbmFtZXNwYWNlIHNvbWVob3cuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RA
bmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
