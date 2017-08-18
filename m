Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:42336 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751350AbdHRS06 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Aug 2017 14:26:58 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: "chuck.lever@oracle.com" <chuck.lever@oracle.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 5/5] SUNRPC: Add a separate spinlock to protect the RPC
 request receive list
Date: Fri, 18 Aug 2017 18:26:54 +0000
Message-ID: <1503080810.11511.2.camel@primarydata.com>
References: <20170816230008.20006-1-trond.myklebust@primarydata.com>
         <20170816230008.20006-2-trond.myklebust@primarydata.com>
         <20170816230008.20006-3-trond.myklebust@primarydata.com>
         <20170816230008.20006-4-trond.myklebust@primarydata.com>
         <20170816230008.20006-5-trond.myklebust@primarydata.com>
         <20170816230008.20006-6-trond.myklebust@primarydata.com>
         <BF5FDF10-EC9C-4F4A-8192-4586CF758099@oracle.com>
In-Reply-To: <BF5FDF10-EC9C-4F4A-8192-4586CF758099@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDE3LTA4LTE4IGF0IDE0OjExIC0wNDAwLCBDaHVjayBMZXZlciB3cm90ZToNCj4g
PiANCj4gc3ZjX3JkbWFfaGFuZGxlX2JjX3JlcGx5IGluDQo+IG5ldC9zdW5ycGMveHBydHJkbWEv
c3ZjX3JkbWFfYmFja2NoYW5uZWwuYw0KPiBhbHNvIG5lZWRzIHRoaXMgY2hhbmdlLg0KDQpHb29k
IHBvaW50LiBJbiBmYWN0IHdlIG5lZWQgaXQgaW4gcmVjZWl2ZV9jYl9yZXBseSgpIHRvby4uLg0K
DQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNsaWVudCBtYWludGFpbmVyLCBQcmlt
YXJ5RGF0YQ0KdHJvbmQubXlrbGVidXN0QHByaW1hcnlkYXRhLmNvbQ0K

