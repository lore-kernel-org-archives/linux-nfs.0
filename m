Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:34151 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377AbbD0K1D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2015 06:27:03 -0400
MIME-Version: 1.0
In-Reply-To: <87wq1063qm.fsf@rasmusvillemoes.dk>
References: <cover.1429868795.git.agruenba@redhat.com>
	<ffc9b1f141b8fb65a958234ebd73b9408d1f987b.1429868795.git.agruenba@redhat.com>
	<87wq1063qm.fsf@rasmusvillemoes.dk>
Date: Mon, 27 Apr 2015 12:27:02 +0200
Message-ID: <CAHpGcMJQ1MDn87A28VAbZQQgv_aFGzXi9VL36TdH7QcHFQWERw@mail.gmail.com>
Subject: Re: [RFC v3 04/45] vfs: Shrink struct posix_acl
From: =?UTF-8?Q?Andreas_Gr=C3=BCnbacher?= <andreas.gruenbacher@gmail.com>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-04-25 9:56 GMT+02:00 Rasmus Villemoes <linux@rasmusvillemoes.dk>:
> This doesn't seem right. Wouldn't that scribble over the a_count and
> part of the first struct posix_acl_entry while there might still be rcu
> users?

You are right, this patch is broken. I'll remove it.

Thanks,
Andreas
