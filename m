Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4986 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433Ab2BOPqO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Feb 2012 10:46:14 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Vitaliy Gusev <gusev.vitaliy@nexenta.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs41: Initialize slot->seq_nr at nfs4_init_slot_table()
Date: Wed, 15 Feb 2012 15:46:06 +0000
Message-ID: <1329320764.3364.19.camel@lade.trondhjem.org>
References: <1329256108-1535-1-git-send-email-gusev.vitaliy@nexenta.com>
	 <1329259606.11759.15.camel@lade.trondhjem.org>
	 <4F3AFD84.3020709@nexenta.com>
	 <1329266587.28837.4.camel@lade.trondhjem.org>
	 <20120215005315.GA9018@fieldses.org>
	 <1329270628.28837.15.camel@lade.trondhjem.org>
	 <1329273001.28837.19.camel@lade.trondhjem.org>
	 <077E41FB-D306-45F5-9344-05A15330A483@netapp.com>
In-Reply-To: <077E41FB-D306-45F5-9344-05A15330A483@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAyLTE1IGF0IDE1OjA3ICswMDAwLCBBZGFtc29uLCBBbmR5IHdyb3RlOg0K
PiANCj4gUGxlYXNlIGRvbid0IG1lcmdlIG5mczRfcmVzZXRfc2xvdF90YWJsZXMgYW5kIG5mczRf
aW5pdF9zbG90X3RhYmxlcy4gIEl0ICBhc3N1bWVzIGEgc3RhdGljIGFycmF5IChyZWFsbG9jKSB3
aGljaCBnb2VzIGF3YXkgd2l0aCB0aGUgZHluYW1pYyBzbG90IHRhYmxlIGNvZGUuIEluc3RlYWQs
IHRha2UgYSBsb29rIGF0IHRoZSBwYXRjaCBzZXQgSSBzZW50IG9uIEZlYiAxMg0KDQpXaHkgbm90
PyBUaGVyZSBpcyBfbm9fIGZ1bmN0aW9uYWwgZGlmZmVyZW5jZSBiZXR3ZWVuIHdoYXQNCm5mczRf
cmVzZXRfc2xvdF90YWJsZXMoKSBhbmQgbmZzNF9pbml0X3Nsb3RfdGFibGVzKCkgbmVlZCB0byBk
by4NClRoZXkgYm90aCBuZWVkIHRvIGFsbG9jYXRlIG5ldyBzbG90cyAoY29uZGl0aW9uYWxseSBp
biB0aGUgY2FzZSBvZg0KbmZzNF9yZXNldF9zbG90X3RhYmxlcywgYnV0IHRoZSBjb25kaXRpb24g
aXMgY29tcGF0aWJsZSB3aXRoIHRoZQ0KbmZzNF9pbml0X3Nsb3RfdGFibGVzIGNhc2UpLCBhbmQg
dGhleSBib3RoIG5lZWQgdG8gaW5pdGlhbGlzZSB0aG9zZQ0Kc2xvdHMgdG8gdGhlIHZhbHVlICcx
Jy4NCg0KQUZBSUNTIFRoZXJlIGlzIG5vIHJlYXNvbiBmb3Iga2VlcGluZyB0aG9zZSBhcyAyIHNl
cGFyYXRlIGZ1bmN0aW9ucywgYW5kDQpJIGRvbid0IHNlZSBob3cgdGhlIGR5bmFtaWMgc2Vzc2lv
biBwYXRjaGVzIGNoYW5nZSBhbnl0aGluZyB0byB0aGF0DQpjb25jbHVzaW9uLg0KDQo+IFtQQVRD
SCBWZXJzaW9uIDcgMy8zXSBORlN2NC4xIGF2b2lkIGZyZWVpbmcgc2xvdCB3aGVuIHRhc2tzIGFy
ZSB3YWl0aW5nDQo+IFtQQVRDSCBWZXJzaW9uIDEgMi8zXSBORlN2NC4xIHByZXBhcmUgZm9yIGR5
YW1pYyBzZXNzaW9uIHNsb3RzDQo+IFtQQVRDSCBWZXJzaW9uIDcgMS8zXSBORlM0LjEgY2xlYW4g
dXAgbmZzNF9hbGxvY19zZXNzaW9uDQoNCkkgbmVlZCBhIGZpeCBmb3IgdGhlIDMuMyBmaW5hbC4u
Lg0KDQpUaG9zZSBwYXRjaGVzIGNhbiBiZSBjbGVhbmVkIHVwIGFuZCBtYWRlIHJlYWR5IGZvciAz
LjQgKG5lZWRzIHdvcmsgLQ0KdGhleSB3b24ndCBhcHBseSB0byB0aGUgJ25mcy1mb3ItbmV4dCcg
YnJhbmNoKSwgYnV0IHJpZ2h0IG5vdyB0aGV5J3JlDQpub3Qgc3VmZmljaWVudGx5IHRlc3RlZCBu
b3IgYXJlIHRoZXkgc3VmZmljaWVudGx5IHJldmlld2VkLiBGb3INCmluc3RhbmNlLCBJJ20gbm90
IGhhcHB5IHdpdGggdGhlIGlkZWEgb2YgYWRkaW5nIGEgJ3RrX3ByaXZhdGUnIGZpZWxkIGluDQp0
aGUgc3RydWN0IHJwY190YXNrLg0KDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMg
Y2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0K
d3d3Lm5ldGFwcC5jb20NCg0K
