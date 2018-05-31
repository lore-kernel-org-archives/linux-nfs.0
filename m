Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-cys01nam02on0128.outbound.protection.outlook.com ([104.47.37.128]:45600
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755894AbeEaRws (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 13:52:48 -0400
From: Trond Myklebust <trondmy@hammerspace.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>,
        "miklos@szeredi.hu" <miklos@szeredi.hu>
CC: "agruenba@redhat.com" <agruenba@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "rgoldwyn@suse.de" <rgoldwyn@suse.de>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Subject: Re: nfs4_acl restricts copy_up in overlayfs
Date: Thu, 31 May 2018 17:52:45 +0000
Message-ID: <422b7b0d5911de1d60464f6a4fdc1a1753af6cde.camel@hammerspace.com>
References: <f2af62fdf8a5bb185ec75cff118178d58b28ceb4.camel@hammerspace.com>
         <2cf94c6b-e819-79af-4ac9-3b19d26dc6d9@suse.de>
         <75266c983a03f6dbfd5d1a39c94fa6d56a1a8a22.camel@hammerspace.com>
         <a0617bb0-b7a5-fab2-c72c-595e005bd8f7@suse.de>
         <20180531004554.GA29116@fieldses.org>
         <CAJfpegtoLpwo6aA9=uF72UDaKvv_Q3bUbv778VwnSDa72yO9Mw@mail.gmail.com>
         <128c74cb1507d7eab36ac8d32182dbbc7d3f9f88.camel@hammerspace.com>
         <CAJfpeguK9rmXK4F7wkE8of7gwDTV_KbM4yWAW8iGJ0RvOMH0-g@mail.gmail.com>
         <e692f5a6f612660ad0a64e083ed7a1398629aa6d.camel@hammerspace.com>
         <CAJfpegsW7CwZYJf_EH80aaYotMMBDk1BjR_RA6dz8e=Y3-ox5w@mail.gmail.com>
         <20180531140619.GA1298@fieldses.org>
         <CAJfpegtOz-b6frP_jSEwWmgdjiDNkrT=bZALpf8jVAWPFTRi8g@mail.gmail.com>
In-Reply-To: <CAJfpegtOz-b6frP_jSEwWmgdjiDNkrT=bZALpf8jVAWPFTRi8g@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDE4LTA1LTMxIGF0IDE2OjI2ICswMjAwLCBNaWtsb3MgU3plcmVkaSB3cm90ZToN
Cj4gT24gVGh1LCBNYXkgMzEsIDIwMTggYXQgNDowNiBQTSwgYmZpZWxkc0BmaWVsZHNlcy5vcmcN
Cj4gPGJmaWVsZHNAZmllbGRzZXMub3JnPiB3cm90ZToNCj4gPiBPbiBUaHUsIE1heSAzMSwgMjAx
OCBhdCAwMzozMDowNFBNICswMjAwLCBNaWtsb3MgU3plcmVkaSB3cm90ZToNCj4gPiA+IE9uIFRo
dSwgTWF5IDMxLCAyMDE4IGF0IDM6MTAgUE0sIFRyb25kIE15a2xlYnVzdA0KPiA+ID4gPHRyb25k
bXlAaGFtbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiA+ID4gT24gVGh1LCAyMDE4LTA1LTMxIGF0
IDE0OjU1ICswMjAwLCBNaWtsb3MgU3plcmVkaSB3cm90ZToNCj4gPiA+ID4gPiBPbiBUaHUsIE1h
eSAzMSwgMjAxOCBhdCAyOjQ3IFBNLCBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kbXlAaGFtDQo+ID4g
PiA+ID4gbWVyc3BhY2UuY29tPiB3cm90ZToNCj4gPiA+ID4gPiA+IEknbSBzdGlsbCBpbiBzdHJv
bmcgZGlzYWdyZWVtZW50IHdpdGggdGhlIG1vZGVsIHlvdSBhcmUNCj4gPiA+ID4gPiA+IHByZXNl
bnRpbmcNCj4gPiA+ID4gPiA+IGhlcmUuIEl0IGlzIGEgY2xpZW50IGVuZm9yY2VkIG1vZGVsLCB3
aGljaCBpcyBub3QgZXZlcg0KPiA+ID4gPiA+ID4gZ29pbmcgdG8gYmUNCj4gPiA+ID4gPiA+IGNv
bXBhdGlibGUgd2l0aCB0aGUgTkZTIG1vZGVsLg0KPiA+ID4gPiA+IA0KPiA+ID4gPiA+IEl0J3Mg
dGhlIG9ubHkgc2FuZSBtb2RlbCB0aGF0IG92ZXJsYXlmcyBjYW4gZG8uDQo+ID4gPiA+ID4gDQo+
ID4gPiA+ID4gVGhpbmsgb2YgaXQgdGhpcyB3YXk6ICBjcmVhdGluZyBhbiBpbWFnZSBmaWxlIG9u
IE5GUywNCj4gPiA+ID4gPiBmb3JtYXRpbmcgaXQgdG8NCj4gPiA+ID4gPiBleHQ0IGFuZCBtb3Vu
dGluZyBpdCBsb2NhbGx5IHRocm91Z2ggdGhlIGxvb3AgZGV2aWNlIGlzIG5vdA0KPiA+ID4gPiA+
IGdvaW5nIHRvDQo+ID4gPiA+ID4gYmUgY29tcGF0aWJsZSB3aXRoIHRoZSBORlMgc2VjdXJpdHkg
bW9kZWwgZWl0aGVyLiAgU2hvdWxkIHdlDQo+ID4gPiA+ID4gY2FyZT8NCj4gPiA+ID4gDQo+ID4g
PiA+IFllcyB5b3Ugc2hvdWxkIGNhcmUgYmVjYXVzZSB5b3UgYXJlIHByb3Bvc2luZyB0aGF0IHRo
ZSBzaW1wbGUNCj4gPiA+ID4gYWN0IG9mDQo+ID4gPiA+IG1vdW50aW5nIHRocm91Z2ggb3Zlcmxh
eWZzIHdpbGwgY2hhbmdlIHdobyBjYW4gYWNjZXNzLCByZWFkIGFuZA0KPiA+ID4gPiBtb2RpZnkN
Cj4gPiA+ID4gZXhpc3RpbmcgZmlsZXMgZnJvbSBhIE5GUyBzZXJ2ZXIuDQo+ID4gPiANCj4gPiA+
IE9ubHkgYWNjZXNzL3JlYWQ6IE5GUyBjYW4gb25seSBiZSByZWFkLW9ubHkgbGF5ZXIuICBTbyBp
dCdzDQo+ID4gPiBpbXBvc3NpYmxlDQo+ID4gPiB0byBhY3R1YWxseSBtb2RpZnkgYSBmaWxlIG9u
IE5GUyB0aHJvdWdoIG92ZXJsYXlmcy4NCj4gPiANCj4gPiBJbiBhZGRpdGlvbiB0byBiZWluZyBy
ZWFkLW9ubHksIEkgYXNzdW1lIGl0J3MgYWxzbyB1bmNoYW5naW5nPyAgSQ0KPiA+IHdvbmRlcg0K
PiA+IHdoeSB5b3UnZCB3YW50IHRvIHVzZSBORlMgYXQgYWxsIGZvciB0aGlzIGNhc2UtLXNoYXJp
bmcgYSByZWFkLW9ubHkNCj4gPiBleHQ0LWZvcm1hdHRlZCBibG9jayBkZXZpY2Ugd291bGQgc2Vl
bSBtb3JlIHN0cmFpZ2h0Zm9yd2FyZC4NCj4gDQo+IEFjdHVhbGx5IHdlIGNvdWxkIGFsbG93IGNo
YW5nZXMgb24gdGhlIHNlcnZlciBzaWRlLiAgIE92ZXJsYXlmcyBzb3J0DQo+IG9mIGRvZXMgdGhp
cyBhbHJlYWR5IChjYWxscyB1bmRlcmx5aW5nIGZzJ3MgLT5kX3JldmFsaWRhdGUoKSBmcm9tDQo+
IG92bF9kZW50cnlfcmV2YWxpZGF0ZSgpKS4gIFdoYXQncyBzdGlsbCBuZWVkZWQgaXMgdG8gZGV0
ZWN0IHJlbmFtZSBieQ0KPiByZWNoZWNraW5nIHBhcmVudCBhbmQgZF9uYW1lIHRvIG1hdGNoIG92
ZXJsYXkgZGVudHJ5J3MgcGFyZW50IGFuZA0KPiBkX25hbWUuDQo+IA0KPiBCdXQgYSBzaGFyZWQg
YmxvY2sgZGV2IGNvdWxkIGJlIHVzZWQgaW4gbW9zdCBjYXNlcywgSSBndWVzcy4NCj4gDQoNCldo
eSB3b3VsZCB5b3UgbmVlZCB0byBleHBvcnQgdGhlIGZpbGVzeXN0ZW0gYXMgcmVhZC1vbmx5IGlm
IGl0IGlzIGdvaW5nDQp0byBiZSBvdmVybGF5ZWQgYW55d2F5PyBEbyB0aGUgcmVhZC1vbmx5IHBy
b3RlY3Rpb24gb24gdGhlIGNsaWVudCBzaWRlLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KQ1RP
LCBIYW1tZXJzcGFjZSBJbmMNCjQzMDAgRWwgQ2FtaW5vIFJlYWwsIFN1aXRlIDEwNQ0KTG9zIEFs
dG9zLCBDQSA5NDAyMg0Kd3d3LmhhbW1lci5zcGFjZSBpZD0iLXgtZXZvLXNlbGVjdGlvbi1lbmQt
bWFya2VyIj4=
