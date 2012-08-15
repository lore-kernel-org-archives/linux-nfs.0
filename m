Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:32998 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756173Ab2HOUuz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Aug 2012 16:50:55 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Richard Ems <richard.ems@cape-horn-eng.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Fix Oopses in nfs_lookup_revalidate and
 nfs4_lookup_revalidate
Date: Wed, 15 Aug 2012 20:50:50 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA93AE444@SACEXCMBX04-PRD.hq.netapp.com>
References: <1345063762-32530-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1345063762-32530-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

T24gV2VkLCAyMDEyLTA4LTE1IGF0IDE2OjQ5IC0wNDAwLCBUcm9uZCBNeWtsZWJ1c3Qgd3JvdGU6
DQo+IEZpeCB0aGUgZm9sbG93aW5nIE9vcHMgaW4gMi41LjE6DQoNCkkgbWVhbnQgdG8gd3JpdGUg
My41LjEgb2YgY291cnNlLi4uDQoNCi0tIA0KVHJvbmQgTXlrbGVidXN0DQpMaW51eCBORlMgY2xp
ZW50IG1haW50YWluZXINCg0KTmV0QXBwDQpUcm9uZC5NeWtsZWJ1c3RAbmV0YXBwLmNvbQ0Kd3d3
Lm5ldGFwcC5jb20NCg0K
