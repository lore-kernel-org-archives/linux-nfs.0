Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31344 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032485Ab2CPA2F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 15 Mar 2012 20:28:05 -0400
Received: from vmwexceht03-prd.hq.netapp.com (vmwexceht03-prd.hq.netapp.com [10.106.76.241])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q2G0S0C9015897
	for <linux-nfs@vger.kernel.org>; Thu, 15 Mar 2012 17:28:00 -0700 (PDT)
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 1 07/11] NFSv4.1 Check invalid deviceid upon
 slot table waitq wakeup
Date: Fri, 16 Mar 2012 00:27:59 +0000
Message-ID: <1331857679.24392.9.camel@lade.trondhjem.org>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
	 <1331836850-5195-8-git-send-email-andros@netapp.com>
In-Reply-To: <1331836850-5195-8-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gVGh1LCAyMDEyLTAzLTE1IGF0IDE0OjQwIC0wNDAwLCBhbmRyb3NAbmV0YXBwLmNvbSB3cm90
ZToNCj4gRnJvbTogQW5keSBBZGFtc29uIDxhbmRyb3NAbmV0YXBwLmNvbT4NCj4gDQo+IFJlZ2lz
dGVyIGEgbmV3IGZpbGVsYXlvdXQgRFMgcnBjX2FjdGlvbiBjYWxsYmFjayBmb3Igc2xlZXBpbmcg
b24gdGhlIGZvcmUNCj4gY2hhbm5lbCBzbG90IHRhYmxlIHdhaXRxLiAgQXZvaWQgYW55IGFkZGl0
aW9uYWwgUlBDIEZTTSBzdGF0ZXMNCj4gKHN1Y2ggYXMgdGltZW91dCkgd2hlbiB3YWtpbmcgdXAg
dG8gYW4gaW52YWxpZCBkZXZpY2VpZCBhbmQgcmVzZXQNCj4gdGhlIHRhc2sgZm9yIGlvIHRvIHRo
ZSBNRFMuDQoNCldoeSBjYW4ndCB5b3Ugc2ltcGx5IHB1dCB0aGlzIGNhbGwgdG8gZmlsZWxheW91
dF93cml0ZV9zbGVlcG9uX2NiIGluDQpmaWxlbGF5b3V0X3dyaXRlX3ByZXBhcmUgKGJlZm9yZSBj
YWxsaW5nIG5mczQxX3NldHVwX3NlcXVlbmNlKCkpPw0KDQpTaW5jZSBub3RoaW5nIGlzIGdvaW5n
IHRvIGNoYW5nZSB0aGUgdGFzay0+dGtfYWN0aW9uIGlmDQpuZnM0MV9zZXR1cF9zZXF1ZW5jZSgp
IHB1dHMgeW91IHRvIHNsZWVwLCB3aGF0IHZhbHVlIGRvZXMgdGhlIGNhbGxiYWNrDQphZGQ/DQoN
Ci0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xpZW50IG1haW50YWluZXINCg0KTmV0
QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3Lm5ldGFwcC5jb20NCg0K
