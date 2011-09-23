Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:17006 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981Ab1IWR1H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Sep 2011 13:27:07 -0400
Content-Type: text/plain;
	charset="utf-8"
Subject: RE: [PATCH v6 1/8] SUNRPC: introduce helpers for reference counted rpcbind clients
Date: Fri, 23 Sep 2011 10:26:49 -0700
Message-ID: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B54DB89@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <4E7C9A91.1060301@parallels.com>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6> <4E7899E7.9090809@parallels.com> <4E79A95F.8050304@parallels.com> <4E7C9A91.1060301@parallels.com>
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Stanislav Kinsbursky" <skinsbursky@parallels.com>
Cc: <linux-nfs@vger.kernel.org>, "Pavel Emelianov" <xemul@parallels.com>,
        <neilb@suse.de>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <bfields@fieldses.org>,
        <davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBTdGFuaXNsYXYgS2luc2J1cnNr
eSBbbWFpbHRvOnNraW5zYnVyc2t5QHBhcmFsbGVscy5jb21dDQo+IFNlbnQ6IEZyaWRheSwgU2Vw
dGVtYmVyIDIzLCAyMDExIDEwOjQxIEFNDQo+IFRvOiBNeWtsZWJ1c3QsIFRyb25kDQo+IENjOiBs
aW51eC1uZnNAdmdlci5rZXJuZWwub3JnOyBQYXZlbCBFbWVsaWFub3Y7IG5laWxiQHN1c2UuZGU7
DQo+IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc7
DQo+IGJmaWVsZHNAZmllbGRzZXMub3JnOyBkYXZlbUBkYXZlbWxvZnQubmV0DQo+IFN1YmplY3Q6
IFJlOiBbUEFUQ0ggdjYgMS84XSBTVU5SUEM6IGludHJvZHVjZSBoZWxwZXJzIGZvciByZWZlcmVu
Y2UNCj4gY291bnRlZCBycGNiaW5kIGNsaWVudHMNCj4gDQo+IFRyb25kLCBpcyB0aGlzIHBhdGNo
IHZlcnNpb24gc3VpdHMgeW91IG5vdz8gT3Igbm90Pw0KPiBQbGVhc2UsIGNvbW1lbnQgc29tZWhv
dyB0byBsZXQgbWUga25vdywgbWF5IEkgcHJvY2VlZCB3aXRoIGZ1cnRoZXINCj4gZGV2ZWxvcG1l
bnQgb3Igbm90Lg0KDQpIaSBTdGFuaXNsYXYsDQoNClllcywgdGhpcyB2ZXJzaW9uIG9mIHRoZSBw
YXRjaCBsb29rcyBzYWZlIHRvIG1lLg0KDQpDaGVlcnMNCiAgVHJvbmQNCgTvv717Lm7vv70r77+9
77+977+977+977+977+977+9KyXvv73vv71sendt77+977+9Yu+/veunsu+/ve+/vXLvv73vv716
WO+/ve+/vRnfsinvv73vv73vv713Kh9qZ++/ve+/ve+/vR7vv73vv73vv73vv73vv73domov77+9
77+977+9eu+/vd6W77+977+9Mu+/vd6Z77+977+977+9Ju+/vSnfoe+/vWHvv73vv71/77+977+9
Hu+/vUfvv73vv73vv71o77+9D++/vWo6K3bvv73vv73vv71377+92aU=
