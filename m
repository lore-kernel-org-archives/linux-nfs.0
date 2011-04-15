Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from seldrel01.sonyericsson.com ([212.209.106.2]:17532 "EHLO
	seldrel01.sonyericsson.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751119Ab1DOGBs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Apr 2011 02:01:48 -0400
From: "Finney, Sean" <Sean.Finney@sonyericsson.com>
To: "vovan@vovan.nl" <vovan@vovan.nl>
CC: "mike@it-loops.com" <mike@it-loops.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Fri, 15 Apr 2011 08:01:46 +0200
Subject: Re: [BUG] sec=krb5 mount problem with nfs-utils 1.2.3 on client side
Message-ID: <A50602A820F61543B29992A418BB321B66E18F8A71@seldmbx01.corpusers.net>
References: <20110415010913@it-loops.com>
 <1302840158.2447.5.camel@vovan.net.home>
In-Reply-To: <1302840158.2447.5.camel@vovan.net.home>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

SGkgZ3V5cywKCk9uIEZyaSwgMjAxMS0wNC0xNSBhdCAwNjowMiArMDIwMCwgVmxhZGltaXIgRWxp
c3NlZXYgd3JvdGU6Cj4gTWljaGFlbCwKPiAKPiBJJ3ZlIHBvc3RlZCBhbiBlbWFpbCB3aXRoIHRo
ZSBzYW1lIHF1ZXN0aW9uIGhlcmUgYSBmZXcgd2Vla3MgYWdvLCBidXQgSQo+IGhhdmVuJ3QgYmVl
biBhYmxlIHRvIGludmVzdGlnYXRlIHdoYXQgdGhlIHByb2JsZW0gaXMuIFRoZSBvbmx5Cj4gZGlm
ZmVyZW5jZSBpbiBteSBzZXR1cCwgdGhhdCBzZXJ2ZXJzIGhhdmUga2VybmVsIDIuNi4zNiB0aGUg
cmVzdCBpcwo+IGV4YWN0bHkgdGhlIHNhbWUgYW5kIGV4YWN0bHkgdGhlIHNhbWUgZXJyb3IuIFNl
ZSB0aHJlYWQgd2l0aCB0aGUgc3ViamVjdAo+ICJycGMuc3ZjZ3NzZCBwcm9ibGVtIGFmdGVyIHVw
ZGF0aW5nIGNsaWVudCAxLjIuMi0+MS4yLjMiLgoKSSB0aGluayB0aGUgcHJvYmxlbSBoZXJlIGlz
IHRoZSBzYW1lIG9uZSB3ZSB3ZXJlIGV4cGVyaWVuY2luZywgd2l0aApsYXJnZSBncm91cCBtZW1i
ZXJzaGlwcyBjYXVzaW5nIGludmFsaWQgd3JpdGVzIHRvIHRoZSBwcm9jZnMgcnBjIGNoYW5uZWwK
ZmlsZXMuICBJZiB5b3Ugc3RyYWNlIHJwYy5zdmNnc3NkIChvciBycGMubW91bnRkLCB5b3Ugc2hv
dWxkIHNlZSBpdAp0aGVyZSB0b28gSSB0aGluayksIHlvdSBzaG91bGQgc2VlIHRoZSB3cml0ZSgp
IGNhbGxzIGJlaW5nIHNwbGl0IGludG8KbXVsdGlwbGUgMTAyNC1ieXRlIHNpemVkIHdyaXRlcywg
ZWFjaCBvZiB3aGljaCBnZXQgRUlOVkFMIChvciAtRUlOVkFMLCBJCmZvcmdldCkgcmV0dXJuZWQu
CgpJJ3ZlIHN1Ym1pdHRlZCBhIHBhdGNoIGZvciB0aGF0IGxhc3Qgd2Vlaywgd2hpY2ggaXMgd2Fp
dGluZyBvbgppbmNsdXNpb24uICBJZiB5b3Ugd2FudCB0byB2ZXJpZnksIHBsZWFzZSBsb29rIGJh
Y2sgaW4gdGhlIGFyY2hpdmUgYW5kCnRyeSB0aGUgcGF0Y2ggc3VibWl0dGVkIGluIHRoZSBtYWls
IHdpdGggc3ViamVjdDoKCltQQVRDSCB2Ml0gbmZzLXV0aWxzOiBJbmNyZWFzZSB0aGUgc3RkaW8g
ZmlsZSBidWZmZXIgc2l6ZSBmb3IgcHJvY2ZzCmZpbGVzCgpJdCBzZWVtcyB0byB3b3JrIGhlcmUs
IEknZCBhcHByZWNpYXRlIGlmIHlvdSBjb3VsZCB0cnkgaXQgb3V0IGFuZCBsZXQgbWUKa25vdyBp
ZiBpdCB3b3JrcyBmb3IgeW91IHRvbyA6KQoKCkJSCglTZWFuCgTvv717Lm7vv70r77+977+977+9
77+977+977+977+9KyXvv73vv71sendt77+977+9Yu+/veunsu+/ve+/vXLvv73vv716WO+/ve+/
vRnfsinvv73vv73vv713Kh9qZ++/ve+/ve+/vR7vv73vv73vv73vv73vv73domov77+977+977+9
eu+/vd6W77+977+9Mu+/vd6Z77+977+977+9Ju+/vSnfoe+/vWHvv73vv71/77+977+9Hu+/vUfv
v73vv73vv71o77+9D++/vWo6K3bvv73vv73vv71377+92aU=
