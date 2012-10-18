Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx0.aculab.com ([213.249.233.131]:39704 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751168Ab2JRIik (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Oct 2012 04:38:40 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12574-04 for <linux-nfs@vger.kernel.org>;
 Thu, 18 Oct 2012 09:38:38 +0100 (BST)
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Subject: RE: [PATCH] SUNRPC: Prevent kernel stack corruption on long values of flush
Date: Thu, 18 Oct 2012 09:34:57 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7050@saturn3.aculab.com>
In-Reply-To: <507EF918.5030004@panasas.com>
References: <1342476086-21638-1-git-send-email-levinsasha928@gmail.com> <20120718173913.GA1298@fieldses.org> <20120718200049.GA17964@umich.edu> <20120718203304.GA18540@redhat.com> <20120718205510.GA18374@umich.edu> <507EF918.5030004@panasas.com>
From: "David Laight" <David.Laight@ACULAB.COM>
To: "Boaz Harrosh" <bharrosh@panasas.com>, "Jim Rees" <rees@umich.edu>
Cc: "Dave Jones" <davej@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        "Sasha Levin" <levinsasha928@gmail.com>, <Trond.Myklebust@netapp.com>,
        <davem@davemloft.net>, <linux-nfs@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiAuLi4NCj4gbG9uZyBpcyBhbHdheXMgdGhlIHNhbWUgb3IgYmlnZ2VyIHRoZW4gYSBwb2ludGVy
DQo+IChBIHBvaW50ZXIgbXVzdCBhbHdheXMgZml0IGluIGEgbG9uZykNCj4gLi4uDQoNCkxpbnV4
IG1heSBtYWtlIHRoYXQgYXNzdW1wdGlvbiwgYnV0IGl0IGRvZXNuJ3QgaGF2ZQ0KdG8gYmUgdHJ1
ZS4gNjRiaXQgd2luZG93cyBzdGlsbCBoYXMgMzJiaXQgbG9uZy4NCkM5OSBpbnR0eXBlcy5oIGRl
ZmluZXMgW3VdaW50cHRyX3QgdG8gYmUgYW4gaW50ZWdyYWwgdHlwZQ0KdGhhdCBpcyBsYXJnZSBl
bm91Z2ggdG8gaG9sZCBhIHBvaW50ZXIgdG8gYW55IGRhdGEgaXRlbS4NCihUaGF0IGluIGl0c2Vs
ZiBpcyBwcm9ibGVtYXRpYyBmb3IgaW1wbGVtZW50YXRpb25zIHRoYXQNCmVuY29kZSBtdWx0aXBs
ZSBjaGFyYWN0ZXJzIGludG8gYSBtYWNoaW5lIHdvcmQgYW5kIG5lZWQNCnRvIHVzZSAnZmF0JyBw
b2ludGVycyBpbiBvcmRlciB0byBlbmNvZGUgdGhlIG9mZnNldC4pDQoNCglEYXZpZA0KDQo=
