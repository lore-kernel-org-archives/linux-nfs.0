Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16193 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191Ab2EZT5b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 May 2012 15:57:31 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 8/9] NFSv4.1: Add DESTROY_CLIENTID
Date: Sat, 26 May 2012 19:57:29 +0000
Message-ID: <1338062247.2453.5.camel@lade.trondhjem.org>
References: <1338057600-11130-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1338057600-11130-2-git-send-email-Trond.Myklebust@netapp.com>
	 <1338057600-11130-3-git-send-email-Trond.Myklebust@netapp.com>
	 <1338057600-11130-4-git-send-email-Trond.Myklebust@netapp.com>
	 <1338057600-11130-5-git-send-email-Trond.Myklebust@netapp.com>
	 <1338057600-11130-6-git-send-email-Trond.Myklebust@netapp.com>
	 <1338057600-11130-7-git-send-email-Trond.Myklebust@netapp.com>
	 <1338057600-11130-8-git-send-email-Trond.Myklebust@netapp.com>
	 <8A0B2B0E-910C-4090-B3B1-DE04F8875175@oracle.com>
In-Reply-To: <8A0B2B0E-910C-4090-B3B1-DE04F8875175@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gU2F0LCAyMDEyLTA1LTI2IGF0IDE1OjQzIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
T24gTWF5IDI2LCAyMDEyLCBhdCAyOjM5IFBNLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6DQo+IA0K
PiA+IEVuc3VyZSB0aGF0IHdlIGRlc3Ryb3kgb3VyIGxlYXNlIG9uIGxhc3QgdW5tb3VudA0KPiAN
Cj4gU28gd2h5IGFyZW4ndCB3ZSB1c2luZyBERVNUUk9ZX0NMSUVOVElEIGluIG5mczRfcmVzZXRf
YWxsX3N0YXRlKCkgPw0KDQpUaGV5IGFyZSBkaWZmZXJlbnQgb3BlcmF0aW9ucy4NCg0KSW4gbmZz
NF9yZXNldF9hbGxfc3RhdGUgd2UncmUgZGVjbGFyaW5nIGEgY2xpZW50IHJlYm9vdDogdGhpcyBt
ZWFucyB0aGF0DQp3ZSB3YW50IHRoZSBzZXJ2ZXIgdG8gcmVsZWFzZSBhbGwgb2xkIHN0YXRlIGFz
c29jaWF0ZWQgd2l0aCB0aGlzIGNsaWVudA0KaWQgb24gdGhlIHNlcnZlciBiZWNhdXNlIHdlJ3Jl
IHRyeWluZyB0byBlc3RhYmxpc2ggYSBuZXcgY2xpZW50IGlkLg0KDQpERVNUUk9ZX0NMSUVOVElE
IGlzIHRoZXJlIGluIG9yZGVyIHRvIGRlc3Ryb3kgYSBjbGllbnQgaWQgdGhhdCBpcyBubw0KbG9u
Z2VyIGluIHVzZS4gQWNjb3JkaW5nIHRvIFNlY3Rpb24gMi40LjIgb2YgUkZDNTY2MSB0aGF0IG1l
YW5zIHRoYXQgaXQNCiJjYW5ub3QgYmUgdXNlZCBpZiB0aGVyZSBhcmUgc2Vzc2lvbnMgYXNzb2Np
YXRlZCB3aXRoIHRoZSBjbGllbnQgSUQsIG9yDQpzdGF0ZSB3aXRoIGFuIHVuZXhwaXJlZCBsZWFz
ZSIuIEluIGZhY3QgdGhlIHNlcnZlciBpcyByZXF1aXJlZCB0byByZWplY3QNCm91ciBERVNUUk9Z
X0NMSUVOVElEIGNhbGwgaWYgaXQgdGhpbmtzIHdlIHN0aWxsIGhvbGQgc3RhdGUuDQoNClNvIHdo
aWxlIHdlIGNvdWxkIHBvc3NpYmx5IGNhbGwgREVTVFJPWV9DTElFTlRJRCBhZnRlciBkZWNsYXJp
bmcgdGhlDQpjbGllbnQgcmVib290IChidXQgd2hhdCB3b3VsZCBiZSB0aGUgcG9pbnQ/KSwgd2Ug
Y2FuJ3QgdXNlIGl0IGFzIGENCnN1YnN0aXR1dGUgZm9yIGRvaW5nIHNvIGluIG5mczRfcmVzZXRf
YWxsX3N0YXRlLi4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1h
aW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFw
cC5jb20NCg0K
