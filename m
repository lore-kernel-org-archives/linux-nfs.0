Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:35668 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752285AbdHAR6n (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2017 13:58:43 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
        "davej@codemonkey.org.uk" <davej@codemonkey.org.uk>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "schumaker.anna@gmail.com" <schumaker.anna@gmail.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Subject: Re: [GIT PULL] Please pull NFS client changes for Linux 4.13
Date: Tue, 1 Aug 2017 17:58:38 +0000
Message-ID: <1501610315.73115.1.camel@primarydata.com>
References: <cf7efbe6-899c-368d-6d56-c2cb3eb28acc@gmail.com>
         <20170714142543.k5xcbnb4mww3sxpy@codemonkey.org.uk>
         <20170716211530.sx7mn35f2mhmykug@codemonkey.org.uk>
         <1500245845.13893.3.camel@primarydata.com>
         <20170717030504.qca74wsswct26ytn@codemonkey.org.uk>
         <CA+55aFy6kUwPTbzKebO4=BovEc_Nq3XCoYMeofgCM3ypxrkvJg@mail.gmail.com>
         <20170731154322.tfzkukscda4fe7wm@codemonkey.org.uk>
         <CA+55aFwwkc-YJ8WQzE6Ax3BAJ3XXR8fhN+0AEH_U8TtcQn7opg@mail.gmail.com>
         <20170801155131.xy7nbw5ih7ml5fmf@codemonkey.org.uk>
         <CA+55aFyQdHt0qYQ0uBSK+9wfPOyFfx8mJE4r9FfWoxa3Gyei9g@mail.gmail.com>
         <20170801175031.74llpntgz3qirv3s@codemonkey.org.uk>
In-Reply-To: <20170801175031.74llpntgz3qirv3s@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTA4LTAxIGF0IDEzOjUwIC0wNDAwLCBkYXZlakBjb2RlbW9ua2V5Lm9yZy51
ayB3cm90ZToNCj4gT24gVHVlLCBBdWcgMDEsIDIwMTcgYXQgMTA6MjA6MzFBTSAtMDcwMCwgTGlu
dXMgVG9ydmFsZHMgd3JvdGU6DQo+IA0KPiAgPiBTbyBJIHRoaW5rIHRoZSAncGF0aG5hbWUnIHBh
cnQgbWF5IGFjdHVhbGx5IGJlIGVudGlyZWx5IGEgcmVkDQo+IGhlcnJpbmcsDQo+ICA+IGFuZCBp
dCdzIHRoZSB1bmRlcmx5aW5nIGFjY2VzcyBpdHNlbGYgdGhhdCBqdXN0IHBpY2tzIHVwIGEgcmFu
ZG9tDQo+ICA+IHBvaW50ZXIgZnJvbSBhIHN0YWNrIHRoYXQgbm93IGNvbnRhaW5zIHNvbWV0aGlu
ZyBkaWZmZXJlbnQuIEFuZA0KPiBLQVNBTg0KPiAgPiBkaWRuJ3Qgbm90aWNlIHRoZSBzdGFsZSBz
dGFjayBhY2Nlc3MgaXRzZWxmLCBiZWNhdXNlIHRoZSBzdGFjaw0KPiBzbG90IGlzDQo+ICA+IHN0
aWxsIHZhbGlkIC0gaXQncyBqdXN0IG5vIGxvbmdlciB0aGUgb3JpZ2luYWwgJ3ZlcmlmaWVyJw0K
PiBhbGxvY2F0aW9uLg0KPiAgPiANCj4gID4gT3IgKnNvbWV0aGluZyogbGlrZSB0aGF0Lg0KPiAg
PiANCj4gID4gTm9uZSBvZiB0aGlzIGxvb2tzIGV2ZW4gcmVtb3RlbHkgbmV3LCB0aG91Z2ggLSB0
aGUgY29kZSBzZWVtcyB0bw0KPiBnbw0KPiAgPiBiYWNrIHRvIDIwMDkuIEhhdmUgeW91IGp1c3Qg
Y2hhbmdlZCB3aGF0IHlvdSdyZSB0ZXN0aW5nIHRvIHRyaWdnZXINCj4gID4gdGhlc2UgdGhpbmdz
Pw0KPiANCj4gTm8gaWRlYSB3aHkgaXQgb25seSBqdXN0IHNob3dlZCB1cCwgYnV0IGl0IGlzbid0
IDEwMCUgcmVwcm9kdWNhYmxlDQo+IGVpdGhlci4gIEEgbW9udGggb3Igc28gYWdvIEkgZGlkIGRp
c2FibGUgdGhlIFY0IGNvZGUgb24gdGhlIHNlcnZlcg0KPiBjb21wbGV0ZWx5IChhcyBJIHdhcyB1
c2luZyB2MyBldmVyeXdoZXJlIGVsc2UpLCBzbyBtYXliZSBJIHN0YXJ0ZWQNCj4gaGl0dGluZw0K
PiBhIGZhbGxiYWNrIHBhdGggc29tZXdoZXJlLiAgKnNocnVnKg0KPiANCg0KSSB3b3VsZCBvbmx5
IGV4cGVjdCB5b3UgdG9vIHNlZSBpdCBpZiB5b3UgaW50ZXJydXB0IHRoZSB3YWl0IG9uIHRoZQ0K
YXN5bmNocm9ub3VzIEVYQ0hBTkdFX0lEIGNhbGwgKHdoaWNoIHdvdWxkIGFsbG93IHRoZSBSUEMg
Y2FsbCB0bw0KY29udGludWUgd2hpbGUgdGhlIGNhbGxlciBzdGFjayBpcyB0cmFzaGVkKS4gUHJp
b3IgdG8gY29tbWl0DQo4ZDg5YmQ3MGJjOTM5LCB0aGF0IGNvZGUgcGF0aCB3YXMgZnVsbHkgc3lu
Y2hyb25vdXMsIHNvIHRoZXJlIHdhcyBubw0KaXNzdWUgd2l0aCBpbnRlcnJ1cHRpbmcgdGhlIGNh
bGwuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIs
IFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

