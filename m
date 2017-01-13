Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr20059.outbound.protection.outlook.com ([40.107.2.59]:11488
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750760AbdAMTOt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Jan 2017 14:14:49 -0500
From: Parav Pandit <parav@mellanox.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: RE: [PATCH v1 4/5] xprtrdma: Reduce required number of send SGEs
Date: Fri, 13 Jan 2017 19:14:00 +0000
Message-ID: <VI1PR0502MB3008A3DFC7CDD1573721596FD1780@VI1PR0502MB3008.eurprd05.prod.outlook.com>
References: <20170113173023.32692.30661.stgit@manet.1015granger.net>
 <20170113174322.32692.66126.stgit@manet.1015granger.net>
 <VI1PR0502MB30080923A8B244BBAD059358D1780@VI1PR0502MB3008.eurprd05.prod.outlook.com>
 <706404D7-A179-4E54-A2C7-534FCC1B5745@oracle.com>
In-Reply-To: <706404D7-A179-4E54-A2C7-534FCC1B5745@oracle.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

PiA+PiArCWlhLT5yaV9tYXhfc2dlbm8gPSBtYXhfc2dlIC0gMzsNCj4gPj4NCj4gPg0KPiA+IEkg
ZGlkbid0IG5vdGljZWQgdGhpcyBuZXcgcmlfbWF4X3NnZW5vIHZhcmlhYmxlIGJlaW5nIHVzZWQg
aW4gdGhpcyBwYXRjaCBzZXQuDQo+IERpZCBJIG1pc3M/DQo+IA0KPiBZZXMsIHlvdSBzbmlwcGVk
IG91dCB0aGUgb3RoZXIgaHVuayB3aGVyZSBpdCBpcyB1c2VkLg0KDQpSaWdodC4gSSBzZWUgaXQg
bm93Lg0KPiANCj4gPiBZb3UgYWxzbyBtaWdodCB3YW50IHRvIHJlbmFtZSBpdCB0byByaV9tYXhf
c2dlX251bS4NCj4gPiBSZWdhcmRsZXNzIGZvciBzb21lIGRldmljZSB3aXRoIDMgU0dFcywgcmlf
bWF4X3NnZW5vIHdpbGwgYmVjb21lIHplcm8uIElzDQo+IHRoYXQgZmluZT8NCj4gDQo+IFllcywg
dGhhdCdzIE9LLCBhbmQgdGVzdGVkLiBaZXJvIG1lYW5zIHRoYXQgTkZTIFdSSVRFIGFuZCBTWU1M
SU5LDQo+IHBheWxvYWRzIHdpbGwgYWx3YXlzIGJlIHNlbnQgaW4gYSBSZWFkIGNodW5rLg0KPiAN
Ck9rLiBUaGFua3MuDQoNCj4gDQo+ID4gSXQgd291bGQgYmUgZ29vZCB0byBoYXZlIGRlZmluZSBm
b3IgdGhpcyBtaW5pbXVtIHJlcXVpcmVkIDMgU0dFcyBoZWFkZXINCj4gZmlsZSBzdWNoIGFzIFJQ
Q1JETUFfTUlOX1JFUV9SRUNWX1NHRS4NCj4gDQo+IE9LLg0K
