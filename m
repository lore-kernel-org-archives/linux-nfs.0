Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35142 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751759AbbFYVGV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 17:06:21 -0400
MIME-Version: 1.0
In-Reply-To: <558C5D75.6050608@samba.org>
References: <1435183040-22726-1-git-send-email-agruenba@redhat.com>
	<1435183040-22726-7-git-send-email-agruenba@redhat.com>
	<558C5D75.6050608@samba.org>
Date: Thu, 25 Jun 2015 23:06:20 +0200
Message-ID: <CAHpGcM+AwRubQqX96V3WbwLKXKTfk3YcgFG_eqG6r7cVbCTV-w@mail.gmail.com>
Subject: Re: [RFC v4 06/31] richacl: In-memory representation and helper functions
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: "Stefan (metze) Metzmacher" <metze@samba.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux API Mailing List <linux-api@vger.kernel.org>,
        samba-technical <samba-technical@lists.samba.org>,
        linux-security-module@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

2015-06-25 21:58 GMT+02:00 Stefan (metze) Metzmacher <metze@samba.org>:
> Is that also the on disk representation?

that's not the xattr representation, no.

> I'm wondering if the size of an ace should be dynamic,
> which might make it possible to support other ace types
> in future. E.g. supporting other identities like 128-bit values
> to make it easier to map Windows SIDS.

I'm working on additionally supporting unmapped user@domain and
group@domain identifier strings; we have to deal with that case in the
nfs client; that may be useful for Samba as well.

> Even without 128-bit ids, it would be very useful to mark an
> ace so that it applies to a uid or gid at the same time.
> This would reduce the size of the ace list when Samba uses
> IDMAP_TYPE_BOTH, which means a SID is mapped to a unix id, which
> is user (uid) and group (gid) at the same time. This feature is required
> in order to support SID-Histories on accounts.
> Currently Samba needs to add two aces (one uid and one gid)
> in order to represent one Windows ace.

It's not clear to me if supporting this would be a good idea right now.
The kernel would have to treat each such entry like two separate entries
internally. How would we map a combined user-space "uid + gid"
number to a kernel uid and gid since it could map to two distinct
numbers there?

> I haven't looked at the claims based acls on Windows, but it would be
> good if the new infrastructure is dynamic enough to support something
> like that in a future version.

I don't know, I have yet to see a use case that isn't totally crazy.

Thanks,
Andreas
