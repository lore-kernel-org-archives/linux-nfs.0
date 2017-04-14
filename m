Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:31288 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751854AbdDNTQk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Apr 2017 15:16:40 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "aglo@umich.edu" <aglo@umich.edu>
CC: "Anna.Schumaker@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bjschuma@netapp.com" <bjschuma@netapp.com>
Subject: Re: RFC: fixing kernel oops on interrupted COMMIT from
 nfs_commit_file
Date: Fri, 14 Apr 2017 19:16:34 +0000
Message-ID: <1492197391.123147.1.camel@primarydata.com>
References: <CAN-5tyHD9NspwAzL2YwoQGwcUk52ak0OWZ-dBfwpW6nynAf1Og@mail.gmail.com>
         <1492109480.7917.1.camel@primarydata.com>
         <CAN-5tyGOsUdWgjhNO8gvYabW-wx6ybmwUZGNLfY8rtmBiP=p_w@mail.gmail.com>
         <bed72de9-5cf8-c8a3-f59f-9bf52f3702a1@Netapp.com>
         <9eb6ccc9-501a-5635-05f9-7bd2fd4f4563@Netapp.com>
         <1492116646.11542.1.camel@primarydata.com>
         <CAN-5tyFbuG44eu3WkUprs1Ym3ZA=nfSq3rQ9Zqs5sDCXvuHCpQ@mail.gmail.com>
In-Reply-To: <CAN-5tyFbuG44eu3WkUprs1Ym3ZA=nfSq3rQ9Zqs5sDCXvuHCpQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTA0LTE0IGF0IDExOjU2IC0wNDAwLCBPbGdhIEtvcm5pZXZza2FpYSB3cm90
ZToNCj4gT24gVGh1LCBBcHIgMTMsIDIwMTcgYXQgNDo1MCBQTSwgVHJvbmQgTXlrbGVidXN0DQo+
IDx0cm9uZG15QHByaW1hcnlkYXRhLmNvbT4gd3JvdGU6DQo+ID4gDQo+ID4gU2Vjb25kbHksIGlm
IHlvdSB3YW50IHRvIHJlbGVhc2UgdGhlIHJlcXVlc3QgYW5kIHlvdSBhcmUgbm90IHN1cmUNCj4g
PiB3aGV0aGVyIG9yIG5vdCBpdCBnb3QgY2xlYXJlZCBvZmYgdGhlIGlub2RlJ3MgY2luZm8gY29t
bWl0IGxpc3QNCj4gPiB5ZXQsDQo+ID4geW91IG1heSBhbHNvIG5lZWQgdG8gbG9jayB0aGF0IHJl
cXVlc3QgYW5kIGNhbGwNCj4gPiBuZnNfY2xlYXJfcmVxdWVzdF9jb21taXQoKS4NCj4gDQo+IExv
b2tpbmcgYXQgd2hhdCB0aGUgZnVuY3Rpb24gZG9lcywgSSBkb24ndCBzZWUgd2h5IHRoaXMgaXMg
bmVlZGVkLg0KPiAid2JfcGFnZSIgaXMgTlVMTCBmb3IgdGhpcyB0eXBlIG9mIGNvbW1pdCBhbmQg
dGhlcmUgaXMgbm8gcG5mcyBpbg0KPiB0aGlzDQo+IGNhc2UuDQoNClNvbWV0aGluZyBuZWVkcyB0
byBlbnN1cmUgdGhhdCB0aGUgcmVxdWVzdCBpcyBub3Qgc2l0dGluZyBvbiBhIGNvbW1pdA0KbGlz
dC4gVGhhdCBjYW4gaGFwcGVuIGlmIHRoZSBjb21taXQgc3VjY2VlZGVkLCBidXQgcmV0dXJuZWQg
YSBkaWZmZXJlbnQNCnZlcmlmaWVyLCBvciBpdCBjYW4gaGFwcGVuIGlmIG5mc19zY2FuX2NvbW1p
dCgpIGV4aXRzIGVhcmx5Lg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVu
dCBtYWludGFpbmVyLCBQcmltYXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNv
bQ0K

