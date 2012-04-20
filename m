Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:45410 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753276Ab2DTVjE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 17:39:04 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 21:39:02 +0000
Message-ID: <1334957938.3295.37.camel@lade.trondhjem.org>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
	 <B1E9AAB3-6739-46D5-999A-130494131031@oracle.com>
	 <79682769-1052-4392-A63D-F686A81C2BBE@netapp.com>
	 <41440F4B-99AC-48AC-A1F8-C9A3DED9E76E@netapp.com>
In-Reply-To: <41440F4B-99AC-48AC-A1F8-C9A3DED9E76E@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTA0LTIwIGF0IDIxOjMxICswMDAwLCBBZGFtc29uLCBEcm9zIHdyb3RlOg0K
PiBPbiBBcHIgMjAsIDIwMTIsIGF0IDU6MjUgUE0sIEFkYW1zb24sIERyb3Mgd3JvdGU6DQo+IFRv
IGJlIGNsZWFyOiB0aGUgcHJvYmxlbSBpcyAqbm90KiB3aXRoIElQdjYgYWRkcnMgaW4gRlNfTE9D
QVRJT05TIGF0dHJzLiAgVGhleSB3b3JrIGlmIHRoZSBwYXJlbnQgbW91bnQgaXMgSVB2NC9kbnMu
ICBUaGUgcHJvYmxlbSBpcyB3aGVuIHRoZSBwYXJlbnQgbW91bnQgaXMgSVB2NiAqbm8qIHJlZmVy
cmFscyB3b3JrIChJUHY0LCBJUHY2IG9yIEROUyksIGJlY2F1c2Ugb2YgdGhlIGlzc3VlIGRlc2Ny
aWJlZCBhYm92ZS4NCg0KVGhlcmUgaXMgYSBwcm9ibGVtIHRoZXJlIHRvby4gSWYgeW91IGRvbid0
IGJyYWNrZXQgdGhlIElQdjYgYWRkcmVzcyB0aGF0DQp5b3UgZ2V0IGZyb20gZnNfbG9jYXRpb25z
LCB0aGVuIHlvdSdsbCBoaXQgdGhlIHNhbWUgcHJvYmxlbSBpZiB5b3UgaGl0IGENCnJlZmVycmFs
IG9uIHRoZSByZWZlcnJlZC10byBzZXJ2ZXIuDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51
eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBw
LmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
