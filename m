Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27198 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588Ab2BPTxE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Feb 2012 14:53:04 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/13] NFS: Fix comparison signage warnings with slot ID
 computations
Date: Thu, 16 Feb 2012 19:52:58 +0000
Message-ID: <1329421978.4279.23.camel@lade.trondhjem.org>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net>
	 <20120215213500.3254.16678.stgit@ellison.1015granger.net>
In-Reply-To: <20120215213500.3254.16678.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTAyLTE1IGF0IDE2OjM1IC0wNTAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
VG8gbWFrZSBuZnM0cHJvYy5jIGNvbXBpbGUgY2xlYW5seSwgYWRkcmVzcyB0aGUgZm9sbG93aW5n
IGNvbXBpbGVyDQo+IHdhcm5pbmdzOg0KPiANCj4gZnMvbmZzL25mczRwcm9jLmM6IEluIGZ1bmN0
aW9uIOKAmG5mczRfZnJlZV9zbG904oCZOg0KPiBmcy9uZnMvbmZzNHByb2MuYzozNzE6Mjogd2Fy
bmluZzogY29tcGFyaXNvbiBiZXR3ZWVuIHNpZ25lZCBhbmQNCj4gCQl1bnNpZ25lZCBpbnRlZ2Vy
IGV4cHJlc3Npb25zIFstV3NpZ24tY29tcGFyZV0NCj4gZnMvbmZzL25mczRwcm9jLmM6IEluIGZ1
bmN0aW9uIOKAmG5mczRfcmVzZXRfc2xvdF90YWJsZeKAmToNCj4gZnMvbmZzL25mczRwcm9jLmM6
NTAwMDoxNTogd2FybmluZzogY29tcGFyaXNvbiBiZXR3ZWVuIHNpZ25lZCBhbmQNCj4gCQl1bnNp
Z25lZCBpbnRlZ2VyIGV4cHJlc3Npb25zIFstV3NpZ24tY29tcGFyZV0NCj4gZnMvbmZzL25mczRw
cm9jLmM6IEluIGZ1bmN0aW9uIOKAmG5mczRfaW5pdF9zbG90X3RhYmxl4oCZOg0KPiBmcy9uZnMv
bmZzNHByb2MuYzo1MDY0OjI6IHdhcm5pbmc6IGNvbXBhcmlzb24gYmV0d2VlbiBzaWduZWQgYW5k
DQo+IAkJdW5zaWduZWQgaW50ZWdlciBleHByZXNzaW9ucyBbLVdzaWduLWNvbXBhcmVdDQo+IA0K
PiBXaHkgaXMgbWF4X3JlcXMgYWx3YXlzIHUzMiwgYnV0IG5mczRfc2xvdF90YWJsZS5tYXhfc2xv
dHMgYSBzaWduZWQNCj4gaW50ZWdlcj8NCj4gDQoNClRoZXJlIGlzIGFscmVhZHkgYSBmaXggZm9y
IHRoaXMgaW4gdGhlIG5mcy1mb3ItbmV4dCBicmFuY2guDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0
DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RA
bmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
