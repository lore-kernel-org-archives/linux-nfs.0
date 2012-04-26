Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:44474 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753473Ab2DZP0D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Apr 2012 11:26:03 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve French <smfrench@gmail.com>
CC: David Howells <dhowells@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "wine-devel@winehq.org" <wine-devel@winehq.org>,
        "kfm-devel@kde.org" <kfm-devel@kde.org>,
        "nautilus-list@gnome.org" <nautilus-list@gnome.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "libc-alpha@sourceware.org" <libc-alpha@sourceware.org>
Subject: Re: [PATCH 0/6] Extended file stat system call
Date: Thu, 26 Apr 2012 15:25:59 +0000
Message-ID: <1335453958.9701.10.camel@lade.trondhjem.org>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	 <CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com>
	 <20656.1335450358@redhat.com>
	 <CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com>
In-Reply-To: <CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTA0LTI2IGF0IDA5OjU0IC0wNTAwLCBTdGV2ZSBGcmVuY2ggd3JvdGU6DQo+
IE9uIFRodSwgQXByIDI2LCAyMDEyIGF0IDk6MjUgQU0sIERhdmlkIEhvd2VsbHMgPGRob3dlbGxz
QHJlZGhhdC5jb20+IHdyb3RlOg0KPiA+IFN0ZXZlIEZyZW5jaCA8c21mcmVuY2hAZ21haWwuY29t
PiB3cm90ZToNCj4gPg0KPiA+PiBXb3VsZCBpdCBiZSBiZXR0ZXIgdG8gbWFrZSB0aGUgc3RhYmxl
IHZzIHZvbGF0aWxlIGlub2RlIG51bWJlciBhbiBhdHRyaWJ1dGUNCj4gPj4gb2YgdGhlIHZvbHVt
ZSAgb3Igc29tZXRoaW5nIHJldHVybmVkIGJ5IHRoZSBwcm9wb3NlZCB4c3RhdD8NCj4gPg0KPiA+
IEknbSBub3Qgc3VyZSB3aGF0IHlvdSBtZWFuIGJ5IGEgc3RhYmxlIHZzIGEgdm9sYXRpbGUgaW5v
ZGUgbnVtYmVyLg0KPiANCj4gQm90aCBORlMgYW5kIENJRlMgKGFuZCBTTUIyKSBjYW4gcmV0dXJu
IGlub2RlIG51bWJlcnMgb3IgZXF1aXZhbGVudA0KPiB1bmlxdWUgaWRlbnRpZmllciwgYnV0IGlu
IHRoZSBjYXNlIG9mIENJRlMgc29tZSBvbGQgc2VydmVycyBkb24ndCBzdXBwb3J0IHRoZQ0KPiBj
YWxscyB3aGljaCByZXR1cm4gaW5vZGUgbnVtYmVycyAob3IgZG9uJ3QgcmV0dXJuIHRoZW0gZm9y
IGFsbCBmaWxlIHN5c3RlbQ0KPiB0eXBlcywgV2luZG93cyBGQVQ/KSBzbyBpbiB0aGVzZSBjYXNl
cyBjaWZzIGhhcyB0byBjcmVhdGUgaW5vZGUNCj4gbnVtYmVycyBvbiB0aGUgZmx5DQo+IG9uIHRo
ZSBjbGllbnQuICAgaW5vZGUgbnVtYmVycyBjcmVhdGVkIG9uIHRoZSBjbGllbnQgYXJlIG5vdCAi
c3RhYmxlIiB0aGV5DQo+IGNhbiBjaGFuZ2Ugb24gdW5tb3VudC9yZW1vdW50ICh3aGljaCBjYW4g
Y2F1c2UgcHJvYmxlbXMgZm9yIGJhY2t1cA0KPiBhcHBsaWNhdGlvbnMpLg0KPiANCj4gU2ltaWxh
cmx5IE5GU3Y0IGRvZXMgbm90IHJlcXVpcmUgdGhhdCBzZXJ2ZXJzIGFsd2F5cyByZXR1cm4gc3Rh
YmxlIGlub2RlIG51bWJlcnMNCj4gKHRoYXQgd2lsbCBuZXZlciBjaGFuZ2UpIGFuZCBpbnRyb2R1
Y2VkIGEgY29uY2VwdCBvZiAidm9sYXRpbGUgZmlsZSBoYW5kbGUuIg0KPiBXZSBoYXZlIHJ1biBp
bnRvIHRoaXMgaW4gdHdvIGNhc2VzICh0aGVyZSBhcmUgcHJvYmFibHkgbW9yZSkgLQ0KPiBTcGVj
aWFsaXplZCBORlMgc2VydmVycw0KPiBmb3IgSFBDIHdoaWNoIGRlYWwgd2l0aCBsb3RzIG9mIHRy
YW5zaWVudCBpbm9kZXMsIGFuZCBzZWNvbmQgdGhvc2UgZm9yIHNlcnZlcnMNCj4gd2hpY2ggYmFz
ZSB0aGVyZSBpbm9kZSBudW1iZXIgb24gcGF0aCAoV2luZG93cyBORlM/KS4gIFNlZQ0KPiBodHRw
Oi8vZG9jcy5vcmFjbGUuY29tL2NkL0UxOTA4Mi0wMS84MTktMTYzNC9yZnNyZWZlci0xMzcvaW5k
ZXguaHRtbA0KPiBvciB0aGUgTkZTdjQgUkZDLg0KPiANCj4gQmFzaWNhbGx5IHRoZSBxdWVzdGlv
biBpcyB3aGV0aGVyIGl0IGlzIHdvcnRoIHJlcG9ydGluZyBhIGZsYWcgb24gdGhlDQo+IGNhbGwg
d2hpY2ggcmV0dXJucw0KPiB0aGUgaW5vZGUgbnVtYmVyIHRvIGluZGljYXRlIHRoYXQgdGhlIGlu
b2RlIG51bWJlciBpcyAic3RhYmxlIiAod291bGQgbm90IGNoYW5nZQ0KPiBvbiByZWJvb3Qgb3Ig
cmVjb25uZWN0aW9uKSBvciAidm9sYXRpbGUuIiAgICBTaW5jZSB0aGUgbWFqb3JpdHkgb2YgTkZT
DQo+IGFuZCBTTUIyIHNlcnZlcnMNCj4gY2FuIHJldHVybiBzdGFibGUgaW5vZGUgbnVtYmVycywg
SSBkb24ndCBmZWVsIHN0cm9uZ2x5IGFib3V0IHRoZSBuZWVkDQo+IGZvciBhbiBpbmRpY2F0b3IN
Cj4gb2YgInN0YWJsZSIgdnMuICJ2b2xhdGlsZSIgYnV0IEkgbWVudGlvbiBpdCBiZWNhdXNlIGJh
Y2t1cCBhbmQNCj4gbWlncmF0aW9uIGFwcGxpY2F0aW9ucw0KPiBtZW50aW9uIHRoaXMgKGlmIGlu
b2RlIG51bWJlcnMgYXJlIHZvbGF0aWxlLCB0aGV5IG1heSBoYXZlIHRvIGNoZWNrDQo+IGZvciBo
YXJkbGlua3MgZGlmZmVyZW50bHkNCj4gZm9yIGV4YW1wbGUpDQoNCkkgZG9uJ3QgdW5kZXJzdGFu
ZC4gSWYgdGhlIGZpbGVzeXN0ZW0gZG9lc24ndCBzdXBwb3J0IHJlYWwgaW5vZGUNCm51bWJlcnMs
IHRoZW4gd2h5IHJlcG9ydCB0aGVtIGF0IGFsbD8gV2hhdCB1c2Ugd291bGQgYW4gYXBwbGljYXRp
b24gaGF2ZQ0KZm9yIGFuIGlub2RlIG51bWJlciB0aGF0IGNhbid0IGJlIHVzZWQgdG8gaWRlbnRp
ZnkgaGFyZCBsaW5rZWQgZmlsZXM/DQoNCkNoZWVycw0KICBUcm9uZA0KLS0gDQpUcm9uZCBNeWts
ZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xl
YnVzdEBuZXRhcHAuY29tDQp3d3cubmV0YXBwLmNvbQ0KDQo=
