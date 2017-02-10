Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753534AbdBJTA6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Feb 2017 14:00:58 -0500
Date: Fri, 10 Feb 2017 13:51:38 -0500 (EST)
Message-Id: <20170210.135138.2084086346069765205.davem@davemloft.net>
To: kvalo@codeaurora.org
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-mips@linux-mips.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-wireless@vger.kernel.org, target-devel@vger.kernel.org,
        andrew@lunn.ch, anna.schumaker@netapp.com,
        derek.chickles@caviumnetworks.com, felix.manlunas@caviumnetworks.com,
        bfields@fieldses.org, jlayton@poochiereds.net, jirislaby@gmail.com,
        mcgrof@do-not-panic.com, madalin.bucur@nxp.com,
        UNGLinuxDriver@microchip.com, nab@linux-iscsi.org, mickflemm@gmail.com,
        nicolas.ferre@atmel.com, raghu.vatsavayi@caviumnetworks.com,
        ralf@linux-mips.org, satananda.burla@caviumnetworks.com,
        thomas.petazzoni@free-electrons.com, timur@codeaurora.org,
        trond.myklebust@primarydata.com, vivien.didelot@savoirfairelinux.com,
        woojung.huh@microchip.com
Subject: Re: [PATCH net-next v2 00/12] net: dsa: remove unnecessary phy.h
 include
From: David Miller <davem@davemloft.net>
In-Reply-To: <877f4zjw01.fsf@kamboji.qca.qualcomm.com>
References: <87h944ll0w.fsf@kamboji.qca.qualcomm.com>
        <5fe312c8-e59e-669c-cd29-f6773adcd8e5@gmail.com>
        <877f4zjw01.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RnJvbTogS2FsbGUgVmFsbyA8a3ZhbG9AY29kZWF1cm9yYS5vcmc+DQpEYXRlOiBUaHUsIDA5IEZl
YiAyMDE3IDE2OjEwOjA2ICswMjAwDQoNCj4gRmxvcmlhbiBGYWluZWxsaSA8Zi5mYWluZWxsaUBn
bWFpbC5jb20+IHdyaXRlczoNCj4gDQo+Pj4+IElmIG5vdCwgZm9yIHNvbWV0aGluZyBsaWtlIHRo
aXMgaXQncyBhIG11c3Q6DQo+Pj4+DQo+Pj4+IGRyaXZlcnMvbmV0L3dpcmVsZXNzL2F0aC93aWw2
MjEwL2NmZzgwMjExLmM6MjQ6MzA6IGVycm9yOiBleHBlY3RlZCChKaIgYmVmb3JlIKFib29sog0K
Pj4+PiAgbW9kdWxlX3BhcmFtKGRpc2FibGVfYXBfc21lLCBib29sLCAwNDQ0KTsNCj4+Pj4gICAg
ICAgICAgICAgICAgICAgICAgICAgICAgICAgXg0KPj4+PiBkcml2ZXJzL25ldC93aXJlbGVzcy9h
dGgvd2lsNjIxMC9jZmc4MDIxMS5jOjI1OjM0OiBlcnJvcjogZXhwZWN0ZWQgoSmiIGJlZm9yZSBz
dHJpbmcgY29uc3RhbnQNCj4+Pj4gIE1PRFVMRV9QQVJNX0RFU0MoZGlzYWJsZV9hcF9zbWUsICIg
bGV0IHVzZXIgc3BhY2UgaGFuZGxlIEFQIG1vZGUgU01FIik7DQo+Pj4+ICAgICAgICAgICAgICAg
ICAgICAgICAgICAgICAgICAgICBeDQo+Pj4+IExpa2UgbGlrZSB0aGF0IGZpbGUgbmVlZHMgbGlu
dXgvbW9kdWxlLmggaW5jbHVkZWQuDQo+Pj4gDQo+Pj4gSm9oYW5uZXMgYWxyZWFkeSBmaXhlZCBh
IHNpbWlsYXIgKG9yIHNhbWUpIHByb2JsZW0gaW4gbXkgdHJlZToNCj4+PiANCj4+PiB3aWw2MjEw
OiBpbmNsdWRlIG1vZHVsZXBhcmFtLmgNCj4+PiANCj4+PiBodHRwczovL2dpdC5rZXJuZWwub3Jn
L2NnaXQvbGludXgva2VybmVsL2dpdC9rdmFsby93aXJlbGVzcy1kcml2ZXJzLW5leHQuZ2l0L2Nv
bW1pdC8/aWQ9OTQ5YzJkMDA5Njc1M2Q1MThlZjZlMGJkODQxOGM4MDg2NzQ3MTk2Yg0KPj4+IA0K
Pj4+IEknbSBwbGFubmluZyB0byBzZW5kIHlvdSBhIHB1bGwgcmVxdWVzdCB0b21vcnJvdyB3aGlj
aCBjb250YWlucyB0aGF0DQo+Pj4gb25lLg0KPj4NCj4+IFRoYW5rcyBLYWxsZSENCj4+DQo+PiBE
YXZpZCwgY2FuIHlvdSBob2xkIG9uIHRoaXMgc2VyaWVzIHVudGlsIEthbGxlJ3MgcHVsbCByZXF1
ZXN0IGdldHMNCj4+IHN1Ym1pdHRlZD8gUGFzdCB0aGlzIGVycm9yLCBhbGxtb2Rjb25maWcgYnVp
bGRzIGZpbmUgd2l0aCB0aGlzIHBhdGNoDQo+PiBzZXJpZXMgKGp1c3QgdGVzdGVkKS4gVGhhbmtz
IQ0KPiANCj4gSnVzdCBzdWJtaXR0ZWQgdGhlIHB1bGwgcmVxdWVzdDoNCj4gDQo+IGh0dHBzOi8v
cGF0Y2h3b3JrLm96bGFicy5vcmcvcGF0Y2gvNzI2MTMzLw0KDQpJJ3ZlIHJldHJpZWQgdGhpcyBw
YXRjaCBzZXJpZXMsIGFuZCB3aWxsIHB1c2ggaXQgb3V0IGFzc3VtaW5nIHRoZSBidWlsZA0KY29t
cGxldGVzIHByb3Blcmx5Lg0K
