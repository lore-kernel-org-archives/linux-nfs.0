Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:54715 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757282Ab2BNWqy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Feb 2012 17:46:54 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Vitaliy Gusev <gusev.vitaliy@gmail.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
Date: Tue, 14 Feb 2012 22:46:48 +0000
Message-ID: <1329259606.11759.15.camel@lade.trondhjem.org>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
In-Reply-To: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAyLTE1IGF0IDAxOjQ4ICswNDAwLCBWaXRhbGl5IEd1c2V2IHdyb3RlOg0K
PiBVbmluaXRpYWxpemVkIHNlcV9uciBjYXVzZXMgc2VuZGluZyBmaXJzdCBTRVNTSU9OIHJlcXVl
c3QNCj4gd2l0aCBzYV9zZXF1ZW5jZWlkID0gMC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IFZpdGFs
aXkgR3VzZXYgPGd1c2V2LnZpdGFsaXlAbmV4ZW50YS5jb20+DQoNCkhpIFZpdGFsaXkuDQoNCldo
YXQncyB3cm9uZyB3aXRoIHNhX3NlcXVlbmNlaWQgPT0gMD8gSSBjYW4ndCBzZWUgYW55dGhpbmcg
aW4gdGhlIHNwZWMNCnRoYXQgc3RhdGVzIHRoYXQgdGhlIHNlcXVlbmNlaWQgaXMgc3VwcG9zZWQg
dG8gYmUgaW5pdGlhbGlzZWQgdG8gMS4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5G
UyBjbGllbnQgbWFpbnRhaW5lcg0KDQpOZXRBcHANClRyb25kLk15a2xlYnVzdEBuZXRhcHAuY29t
DQp3d3cubmV0YXBwLmNvbQ0KDQo=
