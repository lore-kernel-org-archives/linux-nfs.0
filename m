Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:36607 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753191AbdHOQN1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Aug 2017 12:13:27 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/3] SUNRPC: Don't hold the transport lock across socket
 copy operations
Date: Tue, 15 Aug 2017 16:13:20 +0000
Message-ID: <1502813598.9053.3.camel@primarydata.com>
References: <20170814191652.18263-1-trond.myklebust@primarydata.com>
         <20170814191652.18263-2-trond.myklebust@primarydata.com>
         <003E7C40-57BD-4F02-9157-97919FA206D5@oracle.com>
         <1502741277.19246.7.camel@primarydata.com>
         <55994DBE-0CE4-450A-8B19-B8C8F4CA0B69@oracle.com>
         <1502743109.19246.19.camel@primarydata.com>
         <7C0D016C-FBC3-4103-BA81-37AE0D6BAF5B@oracle.com>
         <1502759921.22283.23.camel@primarydata.com>
         <DE137089-1D71-47C3-BDC4-3BCE73DF235A@oracle.com>
         <1502809254.7593.19.camel@primarydata.com>
         <AB962563-977C-4903-A188-3AD32B9F0086@oracle.com>
In-Reply-To: <AB962563-977C-4903-A188-3AD32B9F0086@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVHVlLCAyMDE3LTA4LTE1IGF0IDExOjA1IC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
UmV2aWV3ZWQtYnk6IENodWNrIExldmVyIDxjaHVjay5sZXZlckBvcmFjbGUuY29tPg0KDQpUaGFu
a3MhIEkgYWdyZWUgd2l0aCB5b3VyIHByb3Bvc2FsIGZvciBob3cgdG8gYXBwbHkgdGhpcyB0byB0
aGUgUkRNQQ0KY29kZS4gSSdtIGhvcGluZyB5b3Ugd2lsbCBiZSBhYmxlIHRvIGxvb2sgaW50byB0
aGF0IGFuZCBjaGVjayB0aGF0IHRoZQ0KcmVtb3ZhbCBvZiB0cmFuc3BvcnQgbG9jayBwcm90ZWN0
aW9uIHdvbid0IGVuZCB1cCBjYXVzaW5nIGNvcnJ1cHRpb24gb2YNCnRoZSBSRE1BIHN0YXRpc3Rp
Y3MgY291bnRlcnMsIGV0Yy4NCg0KLS0gDQpUcm9uZCBNeWtsZWJ1c3QNCkxpbnV4IE5GUyBjbGll
bnQgbWFpbnRhaW5lciwgUHJpbWFyeURhdGENCnRyb25kLm15a2xlYnVzdEBwcmltYXJ5ZGF0YS5j
b20NCg==

