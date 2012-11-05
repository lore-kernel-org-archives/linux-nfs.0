Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.science-computing.de ([193.197.16.30]:29338 "EHLO
	mx4.science-computing.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752432Ab2KEM6E (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Nov 2012 07:58:04 -0500
Message-ID: <5097B580.7020104@science-computing.de>
Date: Mon, 05 Nov 2012 13:48:00 +0100
From: Johannes Schild <j.schild@science-computing.de>
MIME-Version: 1.0
To: "faibish, sorin" <faibish_sorin@emc.com>
CC: "Peng, Tao" <tao.peng@emc.com>, Jun Xiao <xiaojuntime@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Jason Glasgow <jglasgow@aya.yale.edu>
Subject: Re: pNFS Block layout issues / questions
References: <loom.20110328T230906-552@post.gmane.org> <4D977456.1040303@panasas.com> <loom.20121103T072206-631@post.gmane.org> <1882637210201641A747464075FFC6490291C9@MX101CL02.corp.emc.com> <B99990FD-D4C5-43D1-8096-CDAEE90BECB8@emc.com>
In-Reply-To: <B99990FD-D4C5-43D1-8096-CDAEE90BECB8@emc.com>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

QW0gMDUuMTEuMjAxMiAxMzo0Miwgc2NocmllYiBmYWliaXNoLCBzb3JpbjoKPgo+IFNlbnQgZnJv
bSBTb3JpbidzIGlQYWQKPgo+IE9uIE5vdiA0LCAyMDEyLCBhdCA5OjMzIFBNLCAiUGVuZywgVGFv
IiA8dGFvLnBlbmdAZW1jLmNvbT4gd3JvdGU6Cj4KPj4gSGksCj4+Cj4+IEknbGwgYW5zd2VyIHlv
dXIgcXVlc3Rpb25zIGFzIGZhciBhcyBJIGNhbiwgYnV0IEkgbXlzZWxmIGFtIG5vdCBmYW1pbGlh
ciB3aXRoIExpbnV4IHBuZnMgYmxvY2sgc2VydmVyIGltcGxlbWVudGF0aW9uLgo+Pgo+Pj4gLS0t
LS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0KPj4+IEZyb206IGxpbnV4LW5mcy1vd25lckB2Z2VyLmtl
cm5lbC5vcmcgW21haWx0bzpsaW51eC1uZnMtb3duZXJAdmdlci5rZXJuZWwub3JnXSBPbiBCZWhh
bGYgT2YgSnVuIFhpYW8KPj4+IFNlbnQ6IFNhdHVyZGF5LCBOb3ZlbWJlciAwMywgMjAxMiAzOjI4
IFBNCj4+PiBUbzogbGludXgtbmZzQHZnZXIua2VybmVsLm9yZwo+Pj4gU3ViamVjdDogUmU6IHBO
RlMgQmxvY2sgbGF5b3V0IGlzc3VlcyAvIHF1ZXN0aW9ucwo+Pj4KPj4+IFNlZW1zIHRoZSB0aHJl
YWQgZGlkbid0IGdldCBhbnkgcmVwbHkgZm9yIHF1aXRlIGEgbG9uZyB0aW1lLgo+Pj4KPj4+IEkn
bSB0cnlpbmcgdG8gc2V0IHVwIHBORlMgYmxvY2sgbGF5b3V0IE1EUy9EUyBzZXJ2ZXIsIGFuZCBz
b21lCj4+PiBzaW1pbGFyIHF1ZXN0aW9ucyBhcyBQaGlsLgo+Pj4KPj4+IC0gRm9yIGJsb2NrIGxh
eW91dCwgaXMgaXQgbmVjZXNzYXJ5IHRvIG1ha2UgRFMgZXhwb3J0IG5mcyBzaGFyZT8KPj4gTm8u
IEp1c3QgZXhwb3J0IHlvdXIgZGF0YSBjb25uZWN0aW9uIGlzIGVub3VnaCwgd2hpY2ggZm9yIHBu
ZnMgYmxvY2sgY2FuIGJlIGlzY3NpL0ZTIGV0Yy4KPiBTaG91bGQgYmUgaVNDU0kgLyBGQyBmaWJl
ciBjaGFubmVsLgo+Cj4+PiAtIEhvdyBjb3VsZCBhZGQgYSBibG9jayBsYXlvdXQgRFMgaW50byBw
TkZTIHNlcnZlcj8KPj4gSSBkb24ndCB0aGluayBMaW51eCBwbmZzIGJsb2NrIHNlcnZlciBpbXBs
ZW1lbnRzIHNlcGFyYXRlIERTZXMuIFNvIE1EUy9EUyBoYXMgdG8gYmUgb24gdGhlIHNhbWUgbWFj
aGluZSBmb3IgaXQuCj4gTWF5YmUgSmFzb24gR2xhc2dvdyByZW1lbWJlcnM/Cj4KPj4+IC0gRG9l
cyBzcG5mcyBhbHNvIHdvcmsgZm9yIGJsb2NrIGxheW91dC8KPj4gTGFyZ2VseSB5ZXMuIFRoZSB3
aWtpIHBhZ2UgaGFzIGl0IHRoYXQgcG5mcyBibG9jayBzZXJ2ZXIgaXMgYmFzZWQgb24gc3BuZnMu
Cj4+IGh0dHA6Ly9saW51eC1uZnMub3JnL3dpa2kvaW5kZXgucGhwL1BORlNfQmxvY2tfU2VydmVy
X1NldHVwX0luc3RydWN0aW9ucwo+Pgo+PiBCdXQgSSdtIG5vdCBzdXJlIGlmIHRoZSBjb2RlIHN0
aWxsIHdvcmtzLgpGb3IgbWUgdGhlIGNvZGUgZGlkbid0IHdvcmsuIElmIGkgcmVtZW1iZXIgY29y
cmVjdGx5IEJlbiBIYWxldmV5IHRvbGQKbWUsIHRoYXQgdGhlIGNvZGUgYXJlIG5vdCBtYWludGFp
bmVkIGF0IHRoZSBtb21lbnQuCj4+Cj4+IENoZWVycywKPj4gVGFvCj4+Cj4+IBPvv73vv73subsc
77+9Ju+/vX7vv70m77+9GO+/ve+/vSst77+977+93bYX77+977+9d++/ve+/vcub77+977+977+9
be+/vWLvv73vv71nfsin77+9F++/ve+/vdyofe+/ve+/ve+/vcageu+/vSZqOit277+977+977+9
B++/ve+/ve+/ve+/vXpaK++/ve+/vSt6Zu+/ve+/ve+/vWjvv73vv73vv71+77+977+977+977+9
ae+/ve+/ve+/vXrvv70e77+9d++/ve+/ve+/vT/vv73vv73vv73vv70m77+9Kd+iG2YKPiBO77+9
77+977+977+977+9cu+/ve+/vXnvv73vv73vv71i77+9WO+/ve+/vcendu+/vV7vv70p3rp7Lm7v
v70r77+977+977+977+9e++/ve+/ve+/vSLvv73vv71ebu+/vXLvv73vv71677+9Gu+/ve+/vWjv
v73vv73vv73vv70m77+977+9Hu+/vUfvv73vv73vv71o77+9Ayjvv73pmo7vv73domoi77+977+9
Gu+/vRtt77+977+977+977+977+9eu+/vd6W77+977+977+9Zu+/ve+/ve+/vWjvv73vv73vv71+
77+9bW1sPT0KQmVzdCBSZWdhcmRzCgpKb2hhbm5lcwotLSANClZvcnN0YW5kc3ZvcnNpdHplbmRl
ci9DaGFpcm1hbiBvZiB0aGUgYm9hcmQgb2YgbWFuYWdlbWVudDoNCkdlcmQtTG90aGFyIExlb25o
YXJ0DQpWb3JzdGFuZC9Cb2FyZCBvZiBNYW5hZ2VtZW50Og0KRHIuIEJlcm5kIEZpbmtiZWluZXIs
IE1pY2hhZWwgSGVpbnJpY2hzLCANCkRyLiBBcm5vIFN0ZWl0eiwgRHIuIEluZ3JpZCBaZWNoDQpW
b3JzaXR6ZW5kZXIgZGVzIEF1ZnNpY2h0c3JhdHMvDQpDaGFpcm1hbiBvZiB0aGUgU3VwZXJ2aXNv
cnkgQm9hcmQ6DQpQaGlsaXBwZSBNaWx0aW4NClNpdHovUmVnaXN0ZXJlZCBPZmZpY2U6IFR1ZWJp
bmdlbg0KUmVnaXN0ZXJnZXJpY2h0L1JlZ2lzdHJhdGlvbiBDb3VydDogU3R1dHRnYXJ0DQpSZWdp
c3Rlcm51bW1lci9Db21tZXJjaWFsIFJlZ2lzdGVyIE5vLjogSFJCIDM4MjE5Ngo=

