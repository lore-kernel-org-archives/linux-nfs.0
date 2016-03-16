Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:33104 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbcCPHbZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Mar 2016 03:31:25 -0400
Received: by mail-lf0-f44.google.com with SMTP id h198so12634611lfh.0
        for <linux-nfs@vger.kernel.org>; Wed, 16 Mar 2016 00:31:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87vb4nh406.fsf@notabene.neil.brown.name>
References: <87y49ylq76.fsf@notabene.neil.brown.name> <20160314203846.GA22276@fieldses.org>
 <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com>
 <20160315131959.GA419@fieldses.org> <87vb4nh406.fsf@notabene.neil.brown.name>
From: William Dauchy <wdauchy@gmail.com>
Date: Wed, 16 Mar 2016 08:31:03 +0100
Message-ID: <CAJ75kXaWqMSgjp4U=M5Jz7VUXt_yJTo31MTQV0fh1R1TV9_W7Q@mail.gmail.com>
Subject: Re: [PATCH] sunrpc/cache: drop reference when sunrpc_cache_pipe_upcall()
 detects a race
To: NeilBrown <neilb@suse.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

Thank you for your reply.

On Tue, Mar 15, 2016 at 9:37 PM, NeilBrown <neilb@suse.com> wrote:
> I agree that it isn't needed for stable - the race is tiny and the
> consequence of losing the race is that entries get stuck in the cache
> and possible an exported filesystem cannot be unmounted.

I believe in an industrial usage, this race will become more common;
moreover the consequence of an exported filesystem which can't be
unmounted is not something I can accept in some environment.

I accept your judgment about including it or not in -stable but I am
just complaining about the lack of further consideration for those
type of fixes in nfs generally speaking. In an industrial usage, we
are hitting races way more easily than in a normal usage; lost of them
are already fixed and we do backports ourself. We are at a point where
it becomes almost impossible to come with a proof and say "we are
hitting this race, and this patch fixes the issue, please backport in
-stable".
-- 
William
