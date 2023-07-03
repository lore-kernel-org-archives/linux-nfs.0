Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF8CDEB64DC
	for <linux-nfs@archiver.kernel.org>; Mon,  3 Jul 2023 04:48:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229481AbjGCEsY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 3 Jul 2023 00:48:24 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47416 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229504AbjGCEsW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Jul 2023 00:48:22 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9E0811AB
        for <linux-nfs@vger.kernel.org>; Sun,  2 Jul 2023 21:48:18 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 1B47E218E0;
        Mon,  3 Jul 2023 04:48:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1688359692; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=h/EZ7h6UxhORQqlIGJ3v2FQ5d3ZomNwIfwZHBLA3srU=;
        b=xZIPht5ZfimLdBEQ60lvCKlazR+MN6nwmLg0nP0gC452uEA/kLG96Zm6UAkwfjZi1aiWPe
        FfxwtKWipC1fzRoQmxrvd66a2Pq/l8T2fjxwl/2zDwN70+GjMuzPNxw5foRLFbmgTZXJ0g
        j6j7htykJAVKftab+s/v+7iGuarf6dw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1688359692;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=h/EZ7h6UxhORQqlIGJ3v2FQ5d3ZomNwIfwZHBLA3srU=;
        b=jlexXMYRTp1s53W3Ar6i+Zfna0Q79W5NUPiHH8VcNUoy70QFyAc88AMYOXo4LXLKcYjMaf
        pj7eadwJH/FOyIBw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id CDC2D13276;
        Mon,  3 Jul 2023 04:48:10 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id YZ7GHwpTomROEAAAMHmgww
        (envelope-from <neilb@suse.de>); Mon, 03 Jul 2023 04:48:10 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Chuck Lever" <cel@kernel.org>
Cc:     linux-nfs@vger.kernel.org, "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH RFC 0/4] Encode NFSv4 attributes via a branch table
In-reply-to: <168808788945.7728.6965361432016501208.stgit@manet.1015granger.net>
References: <168808788945.7728.6965361432016501208.stgit@manet.1015granger.net>
Date:   Mon, 03 Jul 2023 14:48:07 +1000
Message-id: <168835968730.8939.17203263812842647260@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 30 Jun 2023, Chuck Lever wrote:
> Here's something just for fun. I've converted nfsd4_encode_fattr4()
> to use a bitmask loop, calling an encode helper for each attribute
> to be encoded. Rotten tomatoes and gold stars are both acceptible.

Tomatoes or stars .... it is a hard choice :-)

I wonder what the compiler does with this code.
If it unrolls the loop and inlines the functions - which it probably can
do as the array of pointers is declared const - you end up with much the
same result as the current code.

And I wonder where the compiler puts the code in each conditional now.
If it assumes an if() is unlikely, then it would all be out-of-line
which sounds like part of your goal (or maybe just a nice-to-have).

If the compiler does, or can be convinced to, do the unroll and inline
and unlikely optimisations, then I think I'd give this a goal star.

I guess in practice some of the attributes are "likely" and many are
"unlikely".  With the current code we could easily annotate that if we
wanted to and thought (or measured) there was any value.  With the
looping code we cannot really annotate the likelihood of each.

The code-generation idea is intriguing.  Even if we didn't reach that
goal, having the code highly structured as though it were auto-generated
would be no bad thing.

Thanks,
NeilBrown
