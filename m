Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755426Ab2DTV61 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Apr 2012 17:58:27 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
CC: Jim Rees <rees@umich.edu>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS4: fix referrals with IPv6 mounts
Date: Fri, 20 Apr 2012 21:58:26 +0000
Message-ID: <1334959106.3295.43.camel@lade.trondhjem.org>
References: <1334949705-33393-1-git-send-email-dros@netapp.com>
	 <20120420194504.GA10259@umich.edu>
	 <EA178ED0-5813-4235-A0CF-CF9D54AFB04F@netapp.com>
	 <1334952788.3295.24.camel@lade.trondhjem.org>
	 <A3FAE1E4-2AB8-4AF0-AC46-77EA3E4B9AB2@netapp.com>
	 <1334957730.3295.35.camel@lade.trondhjem.org>
	 <9AAD6718-5A17-482C-8AC1-A6F676838AF0@netapp.com>
	 <1334958209.3295.39.camel@lade.trondhjem.org>
	 <A74D78B5-728F-45EE-8A02-6FDBE0D5ABB2@netapp.com>
In-Reply-To: <A74D78B5-728F-45EE-8A02-6FDBE0D5ABB2@netapp.com>
Content-Type: multipart/mixed;
	boundary="_002_1334959106329543camelladetrondhjemorg_"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--_002_1334959106329543camelladetrondhjemorg_
Content-Type: text/plain; charset="utf-8"
Content-ID: <E9828031560E1E45800DC733B38E4351@tahoe.netapp.com>
Content-Transfer-Encoding: base64

T24gRnJpLCAyMDEyLTA0LTIwIGF0IDIxOjQ4ICswMDAwLCBBZGFtc29uLCBEcm9zIHdyb3RlOg0K
PiBPbiBBcHIgMjAsIDIwMTIsIGF0IDU6NDMgUE0sIE15a2xlYnVzdCwgVHJvbmQgd3JvdGU6DQo+
IA0KPiA+IE9uIEZyaSwgMjAxMi0wNC0yMCBhdCAyMTozOCArMDAwMCwgQWRhbXNvbiwgRHJvcyB3
cm90ZToNCj4gPiANCj4gPj4gWWVzLCBzb21ldGhpbmcgbGlrZSB0aGF0IGNvdWxkIHdvcmssIGJ1
dCB3ZSBzdGlsbCBoYXZlIHRoZSBzYW1lIGlzc3VlIC0gZGVudHJ5LT5kX2ZzZGF0YSBuZXZlciBo
YXMgW10gZXNjYXBpbmcuDQo+ID4gDQo+ID4gVGhhdCdzIGEgYnVnIHRvby4uLiANCj4gDQo+IFJp
Z2h0ISBUaGlzIGlzIHdoYXQgSSd2ZSBiZWVuIHRhbGtpbmcgYWJvdXQgdGhlIHdob2xlIHRpbWUg
LSBJIGd1ZXNzIEkgZGlkbid0IGRvIGEgZ29vZCBqb2IgZXhwbGFpbmluZyBpdCA6KSAgVGhlIG9y
aWdpbmFsIGJ1ZyAoc3BsaXR0aW5nIHJldHVybiBvZiBuZnNfcGF0aCgpKSB3b3VsZCBiZSB0cml2
aWFsIHRvIGZpeCBpZiBkX2ZzZGF0YSBoYWQgW10gZXNjYXBpbmcuDQo+IA0KPiBTbyBJIGd1ZXNz
IHRoYXQgYW5zd2VycyBteSBlYXJsaWVyIHF1ZXN0aW9uIC0gd2UgKmRvKiB3YW50IHRvIGNoYW5n
ZSBkZXZfbmFtZSB0byBpbmNsdWRlIFtdIGVzY2FwaW5nLg0KPiANCj4gLWRyb3MNCg0KSGVyZSBp
cyBhIHBhdGNoIGZyb20gSmFuIEthcmEgdGhhdCBkb2VzIGp1c3QgdGhpcy4gSSdsbCBzdGFydCBi
eQ0KYXBwbHlpbmcgdGhhdC4uLg0KDQotLSANClRyb25kIE15a2xlYnVzdA0KTGludXggTkZTIGNs
aWVudCBtYWludGFpbmVyDQoNCk5ldEFwcA0KVHJvbmQuTXlrbGVidXN0QG5ldGFwcC5jb20NCnd3
dy5uZXRhcHAuY29tDQoNCg==

--_002_1334959106329543camelladetrondhjemorg_
Content-Type: message/rfc822
Content-Disposition: attachment;
	creation-date="Fri, 20 Apr 2012 21:58:25 GMT";
	modification-date="Fri, 20 Apr 2012 21:58:25 GMT"
Content-ID: <83DD52B978650F49BD30227511BEFBA0@tahoe.netapp.com>

Received: from sacrsexc2-prd.hq.netapp.com ([10.99.115.28]) by
 SACMVEXC2-PRD.hq.netapp.com with Microsoft SMTPSVC(6.0.3790.3959); Fri, 2 Sep
 2011 16:10:20 -0700
Received: from smtp1.corp.netapp.com ([10.57.156.124]) by
 sacrsexc2-prd.hq.netapp.com with Microsoft SMTPSVC(6.0.3790.3959); Fri, 2 Sep
 2011 16:10:20 -0700
Received: from mx2.netapp.com (mx2.dmz.netapp.com [10.254.64.58]) by
 smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p82NAKwf017847
 for <Trond.Myklebust@netapp.com>; Fri, 2 Sep 2011 16:10:20 -0700 (PDT)
X-IronPort-Anti-Spam-Filtered: true
X-IronPort-Anti-Spam-Result: AqUAAI9hYU7Dh9wPkWdsb2JhbABCqH0BAQEBCQsLBxQFIYFIfoENMROHdLg6hmUEkyyIP4hQ
X-IronPort-AV: E=Sophos;i="4.68,321,1312182000";  d="scan'208";a="578046674"
X-SBRS: 4.5
Received: from cantor2.suse.de (HELO mx2.suse.de) ([195.135.220.15]) by
 mx2.netapp.com with ESMTP/TLS/DHE-RSA-AES256-SHA; 02 Sep 2011 16:05:03 -0700
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.221.2]) (using
 TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits)) (No client certificate
 requested) by mx2.suse.de (Postfix) with ESMTP id D4C248B013; Sat,  3 Sep
 2011 01:09:50 +0200 (CEST)
Received: by quack.suse.cz (Postfix, from userid 1000) id F209120588; Sat,  3
 Sep 2011 01:09:49 +0200 (CEST)
From: Jan Kara <jack@suse.cz>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Jan Kara <jack@suse.cz>, Josh Boyer
	<jwboyer@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] nfs: Enclose hostname in brackets when needed in
 nfs_do_root_mount
Date: Sat, 3 Sep 2011 01:09:43 +0200
Message-ID: <1315004983-10271-1-git-send-email-jack@suse.cz>
X-Mailer: git-send-email 1.7.1
Return-Path: jack@suse.cz
X-OriginalArrivalTime: 02 Sep 2011 23:10:20.0915 (UTC)
 FILETIME=[7CBD3430:01CC69C5]
X-Evolution-Source: exchange://trond@SACMVEXC2-PRD.hq.netapp.com/
X-Evolution-Source: local
Content-Transfer-Encoding: 7bit
Content-Type: text/plain
MIME-Version: 1.0

When hostname contains colon (e.g. when it is an IPv6 address) it needs
to be enclosed in brackets to make parsing of NFS device string possible.
Fix nfs_do_root_mount() to enclose hostname properly when needed. NFS code
actually does not need this as it does not parse the string passed by
nfs_do_root_mount() but the device string is exposed to userspace in
/proc/mounts.

CC: Josh Boyer <jwboyer@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 fs/nfs/super.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b961cea..42b74f8 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2694,11 +2694,15 @@ static struct vfsmount *nfs_do_root_mount(struct file_system_type *fs_type,
 	char *root_devname;
 	size_t len;
 
-	len = strlen(hostname) + 3;
+	len = strlen(hostname) + 5;
 	root_devname = kmalloc(len, GFP_KERNEL);
 	if (root_devname == NULL)
 		return ERR_PTR(-ENOMEM);
-	snprintf(root_devname, len, "%s:/", hostname);
+	/* Does hostname needs to be enclosed in brackets? */
+	if (strchr(hostname, ':'))
+		snprintf(root_devname, len, "[%s]:/", hostname);
+	else
+		snprintf(root_devname, len, "%s:/", hostname);
 	root_mnt = vfs_kern_mount(fs_type, flags, root_devname, data);
 	kfree(root_devname);
 	return root_mnt;
-- 
1.7.1


--_002_1334959106329543camelladetrondhjemorg_--
