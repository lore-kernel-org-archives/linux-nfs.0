Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:54463 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753910AbdKXReJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Nov 2017 12:34:09 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "jlayton@kernel.org" <jlayton@kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "dvyukov@google.com" <dvyukov@google.com>,
        "anna.schumaker@netapp.com" <anna.schumaker@netapp.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
CC: "syzkaller@googlegroups.com" <syzkaller@googlegroups.com>
Subject: Re: sunrpc: infinite unkillable console spam in xs_tcp_setup_socket
Date: Fri, 24 Nov 2017 17:34:04 +0000
Message-ID: <1511544841.14300.4.camel@primarydata.com>
References: <CACT4Y+bXN5vHCcwEk9NYbPe=RXmweMK09g=nW5D5ww+PTegL5w@mail.gmail.com>
In-Reply-To: <CACT4Y+bXN5vHCcwEk9NYbPe=RXmweMK09g=nW5D5ww+PTegL5w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDE3LTExLTIwIGF0IDE0OjAyICswMTAwLCBEbWl0cnkgVnl1a292IHdyb3RlOg0K
PiBIZWxsbywNCj4gDQo+IFRoZSBmb2xsb3dpbmcgcHJvZ3JhbSB0cmlnZ2VycyBpbmZpbml0ZSBz
dHJlYW0gb2YgdGhlIGZvbGxvd2luZw0KPiBvdXRwdXQNCj4gb24gY29uc29sZS4gVGhlIHByb2dy
YW0gaXMgdW5raWxsYWJsZSBhbmQgdGhpcyBlZmZlY3RpdmVseSBicmluZ3MgdGhlDQo+IG1hY2hp
bmUgZG93bjoNCj4gDQo+IA0KPiAqKiAxNiBwcmludGsgbWVzc2FnZXMgZHJvcHBlZCAqKiBbMTI4
NzUuMDIyOTE3XSB4c190Y3Bfc2V0dXBfc29ja2V0Og0KPiBjb25uZWN0IHJldHVybmVkIHVuaGFu
ZGxlZCBlcnJvciAtMTEzDQo+DQoNCkRvZXMgdGhlIGZvbGxvd2luZyBmaXggdGhlIGlzc3VlPw0K
DQo4PC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
DQpGcm9tIGY0OGQzZjAxZGY0NWY1MGYwMTQ1MDYwZjUyNzJjY2YxYWVhODU1YWMgTW9uIFNlcCAx
NyAwMDowMDowMCAyMDAxDQpGcm9tOiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBw
cmltYXJ5ZGF0YS5jb20+DQpEYXRlOiBGcmksIDI0IE5vdiAyMDE3IDEyOjAwOjI0IC0wNTAwDQpT
dWJqZWN0OiBbUEFUQ0hdIFNVTlJQQzogQWxsb3cgY29ubmVjdCB0byByZXR1cm4gRUhPU1RVTlJF
QUNIDQoNClJlcG9ydGVkLWJ5OiBEbWl0cnkgVnl1a292IDxkdnl1a292QGdvb2dsZS5jb20+DQpT
aWduZWQtb2ZmLWJ5OiBUcm9uZCBNeWtsZWJ1c3QgPHRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0
YS5jb20+DQotLS0NCiBuZXQvc3VucnBjL3hwcnRzb2NrLmMgfCAxICsNCiAxIGZpbGUgY2hhbmdl
ZCwgMSBpbnNlcnRpb24oKykNCg0KZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydHNvY2suYyBi
L25ldC9zdW5ycGMveHBydHNvY2suYw0KaW5kZXggNGRhZDVkYTM4OGQ2Li44Y2I0MGY4ZmZhNWIg
MTAwNjQ0DQotLS0gYS9uZXQvc3VucnBjL3hwcnRzb2NrLmMNCisrKyBiL25ldC9zdW5ycGMveHBy
dHNvY2suYw0KQEAgLTI0MzcsNiArMjQzNyw3IEBAIHN0YXRpYyB2b2lkIHhzX3RjcF9zZXR1cF9z
b2NrZXQoc3RydWN0IHdvcmtfc3RydWN0ICp3b3JrKQ0KIAljYXNlIC1FQ09OTlJFRlVTRUQ6DQog
CWNhc2UgLUVDT05OUkVTRVQ6DQogCWNhc2UgLUVORVRVTlJFQUNIOg0KKwljYXNlIC1FSE9TVFVO
UkVBQ0g6DQogCWNhc2UgLUVBRERSSU5VU0U6DQogCWNhc2UgLUVOT0JVRlM6DQogCQkvKg0KLS0g
DQoyLjE0LjMNCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGllbnQgbWFpbnRh
aW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5jb20NCg==

