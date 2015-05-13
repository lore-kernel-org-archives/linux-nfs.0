Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:36286 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965606AbbEMXwx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2015 19:52:53 -0400
MIME-Version: 1.0
In-Reply-To: <0b3401d08dcf$fe32c070$fa984150$@mindspring.com>
References: <cover.1429868795.git.agruenba@redhat.com>
	<28e2cd75064ff56bad897b6f69356f4fb15b8128.1429868795.git.agruenba@redhat.com>
	<0b2401d08da6$dad0d0f0$907272d0$@mindspring.com>
	<CAHpGcMLBb+s7iSv9SN1eRX-46VU_wnbGX1nXrNkuaYVp8v0jYw@mail.gmail.com>
	<0b2f01d08dbc$d3418940$79c49bc0$@mindspring.com>
	<CAHpGcM+t00=QjR5S+aoi_o=REdnTT7r_K0M7vh7fGESmtQP=_w@mail.gmail.com>
	<0b3401d08dcf$fe32c070$fa984150$@mindspring.com>
Date: Thu, 14 May 2015 01:52:52 +0200
Message-ID: <CAHpGcM+h6NmJ8F5B+bPAtaNXVeLUiGh-BetpjQLcU_-1Zwbd=Q@mail.gmail.com>
Subject: Re: [RFC v3 20/45] richacl: Automatic Inheritance
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-05-14 0:56 GMT+02:00 Frank Filz <ffilzlnx@mindspring.com>:
> I'm not clear what the RICHACL_PROTECTED flag actually does. It looks like it's
> only tested in chmod, and then only if the mode matches the mask (at least if I'm
> understanding the code right).

User space may propagate automatically inherited permissions to files
which are subject to automatic inheritance (RICHACL_AUTO_INHERIT) and
which are not protected from being modified (RICHACL_PROTECTED).

In richacl_chmod(), we simply detect when a chmod has no effect on the
acl: this is when the file masks are already correct, when the acl is
already masked, and when Automatic Inheritance won't affect the acl.

Andreas
