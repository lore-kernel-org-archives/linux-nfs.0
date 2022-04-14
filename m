Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EA86C433F5
	for <linux-nfs@archiver.kernel.org>; Thu, 14 Apr 2022 04:13:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237838AbiDNEPs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Apr 2022 00:15:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36598 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229485AbiDNEPr (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Apr 2022 00:15:47 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.220.29])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5FE56205F8
        for <linux-nfs@vger.kernel.org>; Wed, 13 Apr 2022 21:13:23 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id DDE8E1F85D;
        Thu, 14 Apr 2022 04:13:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1649909601; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=brMLkCIJgdDwhtfZAmnV0AQ6I1m7Q+yPzA7fLCfc+3Y=;
        b=FrVTPK12760u/y3Tm5/cDMGaKRqCtqCIeINSxBKMs30fM6EMnb02Z9Qaxes4H/mFgVwvLV
        MoaOy6uuQN8iiYVuH8QoSSfDbmJo8R0fL6xpP2q68V4ufB2ZZwLJSe0QUiYHJjEbMhPSJN
        OOAanrP738dZoxY54ngP96mMse3XtEY=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1649909601;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=brMLkCIJgdDwhtfZAmnV0AQ6I1m7Q+yPzA7fLCfc+3Y=;
        b=XpMT0tDJnpC6TmszT5xK0aS2w50QKkEVeLIQew5G4C2C6kXA7QZnteKVbAOGai3niTOZgk
        ElviKUwLXKoKu0DQ==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 1553E134D9;
        Thu, 14 Apr 2022 04:13:20 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id 9iegMGCfV2KqGwAAMHmgww
        (envelope-from <neilb@suse.de>); Thu, 14 Apr 2022 04:13:20 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Chuck Lever III" <chuck.lever@oracle.com>
Cc:     "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Documentation: Add an explanation of NFSv4 client identifiers
In-reply-to: <4918188E-9271-47F2-8F5A-D6D5BEB85F36@oracle.com>
References: <164970912423.2037.12497015321508491456.stgit@bazille.1015granger.net>,
 <164974719723.11576.583440068909686735@noble.neil.brown.name>,
 <4918188E-9271-47F2-8F5A-D6D5BEB85F36@oracle.com>
Date:   Thu, 14 Apr 2022 14:13:17 +1000
Message-id: <164990959799.11576.7740616159032491033@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, 13 Apr 2022, Chuck Lever III wrote:
> 
> > On Apr 12, 2022, at 3:06 AM, NeilBrown <neilb@suse.de> wrote:
> > 
> > On Tue, 12 Apr 2022, Chuck Lever wrote:
> >> +
> >> +If a client's "co_ownerid" string or principal are not stable,
> >> +state recovery after a server or client reboot is not guaranteed.
> >> +If a client unexpectedly restarts but presents a different
> >> +"co_ownerid" string or principal to the server, the server orphans
> >> +the client's previous open and lock state. This blocks access to
> >> +locked files until the server removes the orphaned state.
> >> +
> >> +If the server restarts and a client presents a changed "co_ownerid"
> >> +string or principal to the server, the server will not allow the
> >> +client to reclaim its open and lock state, and may give those locks
> >> +to other clients in the mean time. This is referred to as "lock
> >> +stealing".
> > 
> > This is not a possible scenario with Linux NFS client.  The client
> > assembles the string once from various sources, then uses it
> > consistently at least until unmount or reboot.  Is it worth mentioning?
> 
> Neil, thanks for the eyes-on. I've integrated the other suggestions
> in your reply. However there are some corner cases here that I'd
> like to consider before proceeding.
> 
> Generally, preserving the cl_owner_id string is good defense against
> lock stealing. Looks like the Linux NFS client didn't do that before
> ceb3a16c070c ("NFSv4: Cache the NFSv4/v4.1 client owner_id in the
> struct nfs_client").
> 
> If a server filesystem is migrated to a server that the client hasn't
> contacted before, and the client's uniquifier or hostname has changed
> since the client established its lease with the first server, there
> is the possibility of lock stealing during transparent state migration.
> 
> I'm also not certain how the Linux NFS client preserves the principal
> that was used when a lease is first established. It's going to use
> Kerberos if possible, but what if the kernel's cred cache expires and
> the keytab has been altered in the meantime? I haven't walked through
> that code carefully enough to understand whether there is still a
> vulnerability.
> 

I don't think id stability relates to lock stealing.

- global uniqueness guards against stealing
- stability guards against misplacing locks during migration ("stolen"
- seems an inappropriate term as no entity an be blamed for stealing).

Certainly stability of both the identity and the credential are
important.  If that stability is not provided then that is a kernel bug.
As you say, ceb3a16c070c fixed a bug in this area.
I don't think this document is an appropriate place to warn against
kernel bugs - that doesn't fit with the purpose given in the intro.

I don't know know if the credential can change either - I hope not.
IF the credential can actually change, that would be a kernel bug.
IF the same credential cannot be renewed, that is a separate problem,
but should be treated like any other credential that cannot be renewed.

I won't argue strongly against this text - I just don't see how it is
appropriate and think it could be confusing.

Thanks,
NeilBrown
