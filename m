Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1311 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760390Ab2D0SR0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 14:17:26 -0400
Received: from vmwexceht05-prd.hq.netapp.com (vmwexceht05-prd.hq.netapp.com [10.106.77.35])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q3RIHP2o008546
	for <linux-nfs@vger.kernel.org>; Fri, 27 Apr 2012 11:17:25 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Warnings in fs/nfs/write.c and fs/nfs/pnfs.c
Date: Fri, 27 Apr 2012 18:17:24 +0000
Message-ID: <1335550644.3910.16.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

SGkgRnJlZCwNCg0KVGhlcmUgaXMgc29tZXRoaW5nIHdlaXJkIGdvaW5nIG9uIHdpdGggbmZzX2dl
bmVyaWNfcGdfd3JpdGVwYWdlcygpOiBpZg0KdGhlIGFsbG9jYXRpb24gb2YgdGhlIG5mc193cml0
ZV9oZWFkZXIgZmFpbHMsIHlvdSBjYWxsDQpkZXNjLT5wZ19jb21wbGV0aW9uX29wcy0+ZXJyb3Jf
Y2xlYW51cCgpIG9uIGhkci0+cGFnZXMgKGJlZm9yZSBoZHIgaXMNCmluaXRpYWxpc2VkKS4uLiBT
aG91bGRuJ3QgdGhhdCBiZSBjYWxsZWQgb24gZGVzYy0+cGdfbGlzdD8NCg0KRGl0dG8gaXNzdWUg
d2l0aCBwbmZzX2dlbmVyaWNfcGdfd3JpdGVwYWdlcw0KDQpDaGVlcnMNCiAgVHJvbmQNCi0tIA0K
VHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpU
cm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
