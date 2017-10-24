Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:60443 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751506AbdJXW4r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Oct 2017 18:56:47 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
CC: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [GIT PULL] Please pull NFS client fixes
Date: Tue, 24 Oct 2017 22:56:42 +0000
Message-ID: <1508885800.17878.12.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGkgTGludXMsDQoNClRoZSBmb2xsb3dpbmcgY2hhbmdlcyBzaW5jZSBjb21taXQgMzNkOTMwZTU5
YTk4ZmExMGEwZGI5ZjU2YzdmYTJmMjFhNGFlZjliOToNCg0KICBMaW51eCA0LjE0LXJjNSAoMjAx
Ny0xMC0xNSAyMTowMToxMiAtMDQwMCkNCg0KYXJlIGF2YWlsYWJsZSBpbiB0aGUgZ2l0IHJlcG9z
aXRvcnkgYXQ6DQoNCiAgZ2l0Oi8vZ2l0LmxpbnV4LW5mcy5vcmcvcHJvamVjdHMvdHJvbmRteS9s
aW51eC1uZnMuZ2l0IHRhZ3MvbmZzLWZvci00LjE0LTQNCg0KZm9yIHlvdSB0byBmZXRjaCBjaGFu
Z2VzIHVwIHRvIDUyOGZkMzU0N2JhZDBiZGQzMWM4Zjk4N2U1YmQwMGM4M2RmOGFmMzk6DQoNCiAg
U1VOUlBDOiBEZXN0cm95IHRyYW5zcG9ydCBmcm9tIHRoZSBzeXN0ZW0gd29ya3F1ZXVlICgyMDE3
LTEwLTE5IDEyOjE3OjU2IC0wNDAwKQ0KDQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tDQpORlMgY2xpZW50IGJ1Z2ZpeGVzIGZv
ciBMaW51eCA0LjE0DQoNCkhpZ2h0bGlnaHRzIGluY2x1ZGU6DQoNCi0gRml4IGEgbGlzdCBjb3Jy
dXB0aW9uIGluIHhwcnRfcmVsZWFzZSgpDQotIEZpeCBhIHdvcmtxdWV1ZSBsb2NrZGVwIHdhcm5p
bmcgZHVlIHRvIHVuc2FmZSB1c2Ugb2YgY2FuY2VsX3dvcmtfc3luYygpDQoNCi0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0NClRy
b25kIE15a2xlYnVzdCAoMik6DQogICAgICBTVU5SUEM6IGZpeCBhIGxpc3QgY29ycnVwdGlvbiBp
c3N1ZSBpbiB4cHJ0X3JlbGVhc2UoKQ0KICAgICAgU1VOUlBDOiBEZXN0cm95IHRyYW5zcG9ydCBm
cm9tIHRoZSBzeXN0ZW0gd29ya3F1ZXVlDQoNCiBuZXQvc3VucnBjL3hwcnQuYyB8IDM2ICsrKysr
KysrKysrKysrKysrKysrKysrKystLS0tLS0tLS0tLQ0KIDEgZmlsZSBjaGFuZ2VkLCAyNSBpbnNl
cnRpb25zKCspLCAxMSBkZWxldGlvbnMoLSkNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBO
RlMgY2xpZW50IG1haW50YWluZXIsIFByaW1hcnlEYXRhDQp0cm9uZC5teWtsZWJ1c3RAcHJpbWFy
eWRhdGEuY29tDQo=

