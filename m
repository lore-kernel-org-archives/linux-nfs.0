Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:30115 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751776AbdJ3Sfg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Oct 2017 14:35:36 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfsd: On CLOSE, the state change needs to be atomic with
 the seqid bump
Date: Mon, 30 Oct 2017 18:35:31 +0000
Message-ID: <1509388529.95653.4.camel@primarydata.com>
References: <20171027202509.99168-1-trond.myklebust@primarydata.com>
In-Reply-To: <20171027202509.99168-1-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTEwLTI3IGF0IDE2OjI1IC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IFRoZSB2YXJpb3VzIGZ1bmN0aW9ucyB0aGF0IGNhbGwgY2hlY2tfc3RhdGVpZF9nZW5lcmF0
aW9uKCkgaW4gb3JkZXINCj4gdG8gY29tcGFyZSBhIGNsaWVudC1zdXBwbGllZCBzdGF0ZWlkIHdp
dGggdGhlIG5mczRfc3RpZCBzdGF0ZSwgYWxtb3N0DQo+IHdpdGhvdXQgZXhjZXB0aW9uIG5lZWQg
dG8gY2hlY2sgZm9yIGNsb3NlZCBzdGF0ZS4NCj4gDQo+IEEgcmFjZSBub3cgZXhpc3RzIHdoZXJl
YnkgdGhlIHN0YXRlaWQgY2FuIGdldCBidW1wZWQgaW4gbmZzZDRfY2xvc2UsDQo+IGJ1dA0KPiB0
aGUgYWN0dWFsIGNoYW5nZSBpbiB2YWx1ZSBvZiBzdF9zdGlkLnNjX3R5cGUgaXMgZGVmZXJyZWQg
dW50aWwgYWZ0ZXINCj4gYWxsIGxvY2tzIGFyZSBkcm9wcGVkLg0KPiBUaGlzIGNvbW1pdCBlbnN1
cmVzIHRoYXQgdGhlIHN0YXRlIGNoYW5nZSBpcyBsb2dnZWQgd2hpbGUgdGhlIHN0YXRlDQo+IG11
dGV4IGlzIGhlbGQsIGJ1dCBhbHNvIGVuc3VyZXMgdGhhdCBpcyBoYXBwZW5zIGJlZm9yZSB0aGUg
c2VxaWQNCj4gaXMgYnVtcGVkLiBJdCBhbHNvIGFkZHMgbG9ja2luZyBhbmQgY2hlY2tzIHNvIHRo
YXQgZnVuY3Rpb25zIHRoYXQNCj4gY2hlY2sNCj4gdGhlIHNlcWlkIHdpbGwgYWxzbyBzZWUgdGhl
IGNvcnJlY3Qgc3RhdGUuDQo+IA0KDQpUdXJucyBvdXQgdGhpcyBwYXRjaCBpcyBpbnN1ZmZpY2ll
bnQgdG8gcHJldmVudCBhIHJhY2UgYmV0d2VlbiBDTE9TRQ0KYW5kIE9QRU4gd2hlcmVieSB0aGUg
c2VydmVyIGVuZHMgdXAgcmV1c2luZyBhIHN0YXRlaWQgdGhhdCBpcyBhbHJlYWR5DQpjbG9zZWQu
IEkndmUgYmVlbiB0ZXN0aW5nIGEgcGF0Y2ggc2VyaWVzIHRoYXQgYWRkcmVzc2VzIHRoYXQgaXNz
dWUgb3Zlcg0KdGhlIHdlZWtlbmQuIFdpbGwgc2VuZCBhbiB1cGRhdGUgbGF0ZXIgdG9kYXkuDQoN
Ci0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXIsIFByaW1h
cnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFyeWRhdGEuY29tDQo=

