Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:35135 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753321Ab2CERgB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 12:36:01 -0500
Received: from vmwexceht02-prd.hq.netapp.com ([10.106.76.240])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q25HZk0H003265
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 09:35:46 -0800 (PST)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 08/11] NFSv4: Simplify the struct nfs4_stateid
Date: Mon, 5 Mar 2012 17:35:45 +0000
Message-ID: <1330968945.2509.5.camel@lade.trondhjem.org>
References: <1330902183-18879-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1330902183-18879-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1330902183-18879-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1330902183-18879-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1330902183-18879-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1330902183-18879-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1330902183-18879-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1330902183-18879-8-git-send-email-Trond.Myklebust@netapp.com>
	 <4F54F48C.2090703@netapp.com>
In-Reply-To: <4F54F48C.2090703@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gTW9uLCAyMDEyLTAzLTA1IGF0IDEyOjE0IC0wNTAwLCBCcnlhbiBTY2h1bWFrZXIgd3JvdGU6
DQo+IEkganVzdCBmaW5pc2hlZCBiaXNlY3RpbmcgYW4gb29wcyB0byB0aGlzIHBhdGNoLCBkb2Vz
IHYyIGZpeCB0aGUgcHJvYmxlbT8gIEkgaGl0IGl0IHdoaWxlIHJ1bm5pbmcgdGhlIHNwZWNpYWwg
dGVzdHMgb3ZlciB2NC4gIEkgd2FzIGFibGUgdG8gY29tcGlsZSBhZnRlciB0aGVzZSBwYXRjaGVz
LCBzbyB0aGF0J3MgYSBzdGVwIGZvcndhcmQhDQoNCkkndmUgZ290IGEgZml4IGZvciB0aGF0IGlu
IHYzLi4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWlu
ZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20N
Cg0K
