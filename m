Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16339 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab1FANhJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Jun 2011 09:37:09 -0400
Received: from [10.30.3.27] ([10.30.3.27])
	(authenticated bits=0)
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id p51DctJS022684
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 1 Jun 2011 17:38:56 +0400 (MSD)
Message-ID: <4DE64082.4070604@parallels.com>
Date: Wed, 01 Jun 2011 17:37:06 +0400
From: Vasily Averin <vvs@parallels.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] sunrpc: use dprint_status() macro in call_decode()
Content-Type: multipart/mixed;
 boundary="------------060807050304080006090503"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------060807050304080006090503
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit


--------------060807050304080006090503
Content-Type: text/plain;
 name="diff-sunrpc-debug-20110601-1"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="diff-sunrpc-debug-20110601-1"

RnJvbSA5ZWNlNzBlOTk2NDA5ZTkxMzcxMjc1MzE5YjNiZjY3M2UyNTkxNmUyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBWYXNpbHkgQXZlcmluIDx2dnNAc3cucnU+CkRhdGU6IFdlZCwg
MSBKdW4gMjAxMSAxNjoyMzo1OSArMDQwMApTdWJqZWN0OiBbUEFUQ0ggMS8yXSBzdW5ycGM6IHVz
ZSBkcHJpbnRfc3RhdHVzKCkgbWFjcm8gaW4gY2FsbF9kZWNvZGUoKQoKY29tbW9uIGRwcmludF9z
dGF0dXMoKSBtYWNybyBpcyB1c2VkIGluIGFsbCBjYWxsYmFja3MgYnV0IG5vdCBpbiBjYWxsX2Rl
Y29kZSgpCgpTaWduZWQtb2ZmLWJ5OiBWYXNpbHkgQXZlcmluIDx2dnNAc3cucnU+Ci0tLQogbmV0
L3N1bnJwYy9jbG50LmMgfCAgICAzICstLQogMSBmaWxlcyBjaGFuZ2VkLCAxIGluc2VydGlvbnMo
KyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy9jbG50LmMgYi9uZXQv
c3VucnBjL2NsbnQuYwppbmRleCBiODRkNzM5Li5hYjU1MzY5IDEwMDY0NAotLS0gYS9uZXQvc3Vu
cnBjL2NsbnQuYworKysgYi9uZXQvc3VucnBjL2NsbnQuYwpAQCAtMTU0OCw4ICsxNTQ4LDcgQEAg
Y2FsbF9kZWNvZGUoc3RydWN0IHJwY190YXNrICp0YXNrKQogCWt4ZHJkcHJvY190CWRlY29kZSA9
IHRhc2stPnRrX21zZy5ycGNfcHJvYy0+cF9kZWNvZGU7CiAJX19iZTMyCQkqcDsKIAotCWRwcmlu
dGsoIlJQQzogJTV1IGNhbGxfZGVjb2RlIChzdGF0dXMgJWQpXG4iLAotCQkJdGFzay0+dGtfcGlk
LCB0YXNrLT50a19zdGF0dXMpOworCWRwcmludF9zdGF0dXModGFzayk7CiAKIAlpZiAodGFzay0+
dGtfZmxhZ3MgJiBSUENfQ0FMTF9NQUpPUlNFRU4pIHsKIAkJaWYgKGNsbnQtPmNsX2NoYXR0eSkK
LS0gCjEuNy40LjEKCg==

--------------060807050304080006090503--
