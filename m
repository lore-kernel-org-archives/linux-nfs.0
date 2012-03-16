Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14096 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757578Ab2CPUOp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 16:14:45 -0400
Received: from vmwexceht01-prd.hq.netapp.com (vmwexceht01-prd.hq.netapp.com [10.106.76.239])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q2GKEhje019225
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 13:14:45 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Isaman, Fred" <Fred.Isaman@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 1/2] NFSv4.1: Clean ups and bugfixes for the pNFS
 read/writeback/commit code
Date: Fri, 16 Mar 2012 20:14:43 +0000
Message-ID: <1331928883.13255.0.camel@lade.trondhjem.org>
References: <1331923433-12055-1-git-send-email-Trond.Myklebust@netapp.com>
	 <CADnza46tR=PvrHBmARQJPyS8iThRzEzHdF6dEMBPxeiEOj4X9w@mail.gmail.com>
In-Reply-To: <CADnza46tR=PvrHBmARQJPyS8iThRzEzHdF6dEMBPxeiEOj4X9w@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gRnJpLCAyMDEyLTAzLTE2IGF0IDE1OjMyIC0wNDAwLCBGcmVkIElzYW1hbiB3cm90ZToNCj4g
T24gRnJpLCBNYXIgMTYsIDIwMTIgYXQgMjo0MyBQTSwgVHJvbmQgTXlrbGVidXN0DQo+IDxUcm9u
ZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbT4gd3JvdGU6DQo+ID4gTW92ZSBtb3JlIHBuZnMtaXNtcyBv
dXQgb2YgdGhlIGdlbmVyaWMgY29tbWl0IGNvZGUuDQoNCj4gPiAtb3V0X3B1dDoNCj4gPiAtICAg
ICAgIHB1dF9sc2VnKGxzZWcpOw0KPiA+ICsgICAgICAgaWYgKHJ2ICE9IDApDQo+ID4gKyAgICAg
ICAgICAgICAgIHNldF9iaXQoTkZTX0lOT19QTkZTX0NPTU1JVCwgJk5GU19JKGlub2RlKS0+Zmxh
Z3MpOw0KPiANCj4gQSBxdWliYmxlLi4uSSB3b3VsZCBwdXQgdGhlIHNldF9iaXQgdXAgYSBsYXll
ciwgaW4gdGhlIGFjdHVhbA0KPiBwbmZzX3NjYW5fY29tbWl0X2xpc3RzIGZ1bmN0aW9uLg0KPiBP
dGhlciB0aGFuIHRoYXQsIGJvdGggcGF0Y2hlcyBsb29rIGdvb2QgdG8gbWUuDQo+IA0KDQpNb3Zp
bmcgaXQgaW50byBwbmZzX3NjYW5fY29tbWl0X2xpc3RzIHNvdW5kcyBmYWlyLi4uDQoNCi0tIA0K
VHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpU
cm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
