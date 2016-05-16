Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:34579 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754356AbcEPTu3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2016 15:50:29 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "hch@infradead.org" <hch@infradead.org>
Subject: Re: [PATCH v3 10/13] pnfs: fix bad error handling in send_layoutget
Date: Mon, 16 May 2016 19:50:07 +0000
Message-ID: <FFD84C76-4FD9-403E-9FDE-4FA51C6F9619@primarydata.com>
References: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
 <1463274402-17746-11-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1463274402-17746-11-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DQoNCk9uIDUvMTQvMTYsIDIxOjA2LCAiSmVmZiBMYXl0b24iIDxqbGF5dG9uQHBvb2NoaWVyZWRz
Lm5ldD4gd3JvdGU6DQoNCj5DdXJyZW50bHksIHRoZSBjb2RlIHdpbGwgY2xlYXIgdGhlIGZhaWwg
Yml0IGlmIHdlIGdldCBiYWNrIGEgZmF0YWwNCj5lcnJvci4gSSBkb24ndCB0aGluayB0aGF0J3Mg
Y29ycmVjdCAtLSB3ZSBvbmx5IHdhbnQgdG8gY2xlYXIgdGhhdA0KPmJpdCBpZiB0aGUgbGF5b3V0
Z2V0IHN1Y2NlZWRzLg0KPg0KPkZpeGVzOiAwYmNiZjAzOWY2IChuZnM6IGhhbmRsZSByZXF1ZXN0
IGFkZCBmYWlsdXJlIHByb3Blcmx5KQ0KPlNpZ25lZC1vZmYtYnk6IEplZmYgTGF5dG9uIDxqZWZm
LmxheXRvbkBwcmltYXJ5ZGF0YS5jb20+DQo+LS0tDQo+IGZzL25mcy9wbmZzLmMgfCA4ICsrKysr
LS0tDQo+IDEgZmlsZSBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25zKC0pDQo+
DQo+ZGlmZiAtLWdpdCBhL2ZzL25mcy9wbmZzLmMgYi9mcy9uZnMvcG5mcy5jDQo+aW5kZXggZTZj
YWQ1ZWU1ZDI5Li41ZjZlZDI5NWFjYjUgMTAwNjQ0DQo+LS0tIGEvZnMvbmZzL3BuZnMuYw0KPisr
KyBiL2ZzL25mcy9wbmZzLmMNCj5AQCAtODc2LDExICs4NzYsMTMgQEAgc2VuZF9sYXlvdXRnZXQo
c3RydWN0IHBuZnNfbGF5b3V0X2hkciAqbG8sDQo+IAkJbHNlZyA9IG5mczRfcHJvY19sYXlvdXRn
ZXQobGdwLCBnZnBfZmxhZ3MpOw0KPiAJfSB3aGlsZSAobHNlZyA9PSBFUlJfUFRSKC1FQUdBSU4p
KTsNCj4gDQo+LQlpZiAoSVNfRVJSKGxzZWcpICYmICFuZnNfZXJyb3JfaXNfZmF0YWwoUFRSX0VS
Uihsc2VnKSkpDQo+LQkJbHNlZyA9IE5VTEw7DQo+LQllbHNlDQo+KwlpZiAoSVNfRVJSKGxzZWcp
KSB7DQo+KwkJaWYgKCFuZnNfZXJyb3JfaXNfZmF0YWwoUFRSX0VSUihsc2VnKSkpDQo+KwkJCWxz
ZWcgPSBOVUxMOw0KPisJfSBlbHNlIHsNCj4gCQlwbmZzX2xheW91dF9jbGVhcl9mYWlsX2JpdChs
bywNCj4gCQkJCXBuZnNfaW9tb2RlX3RvX2ZhaWxfYml0KHJhbmdlLT5pb21vZGUpKTsNCj4rCX0N
Cg0KTm/igKYgVGhlIGludGVudGlvbiB3YXMgaW5kZWVkIHRoYXQgd2UgY2xlYXIgdGhlIGZhaWwg
Yml0IGluIGFsbCBjYXNlcyBleGNlcHQgZmF0YWwgZXJyb3JzLiBPdGhlcndpc2UsIHRoZSBjbGll
bnQgd29u4oCZdCBhdHRlbXB0IGFub3RoZXIgbGF5b3V0Z2V0Lg0KDQoNCg0K

