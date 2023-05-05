Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84603C77B75
	for <linux-nfs@archiver.kernel.org>; Fri,  5 May 2023 11:07:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231365AbjEELHb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 May 2023 07:07:31 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55202 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229904AbjEELHa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 May 2023 07:07:30 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A72EF18DFA
        for <linux-nfs@vger.kernel.org>; Fri,  5 May 2023 04:07:29 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 6351A227C9;
        Fri,  5 May 2023 11:07:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1683284848; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=g5cfREyDOAuwb2bwzv2RzjxYAX5qIXqER5DWvBxug8U=;
        b=us54k3BLyYEycCb5etJHXp7+ITXwvcUOyR333CfaiOm3GpNdlFHOMsI/N/EelJudMlkyMr
        jwMIcoEEMVlniAlx25gWNuMmjmsGxFRpZXco1fm3dQOh9L8IIYWYJHQVGaAChlfuMioBoI
        7GjMMWGc3T6PVpVuSloehZdlzugka40=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1683284848;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=g5cfREyDOAuwb2bwzv2RzjxYAX5qIXqER5DWvBxug8U=;
        b=gModJmtnQFPddl3RjDtxMbUy6t5JyMVt7R6kikKvPzSDvtDuEPgHNLiLr/b7GLPjEcion2
        53g5VzLx3bQKzLCA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 4BB5413488;
        Fri,  5 May 2023 11:07:28 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id 3gQnEnDjVGRqDgAAMHmgww
        (envelope-from <chrubis@suse.cz>); Fri, 05 May 2023 11:07:28 +0000
Date:   Fri, 5 May 2023 13:08:30 +0200
From:   Cyril Hrubis <chrubis@suse.cz>
To:     Petr Vorel <pvorel@suse.cz>
Cc:     ltp@lists.linux.it, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH v5 5/5] nfs: Run on btrfs, ext4, xfs
Message-ID: <ZFTjrmSdaJaf1Xyq@yuki>
References: <20230504131414.3826283-1-pvorel@suse.cz>
 <20230504131414.3826283-6-pvorel@suse.cz>
 <ZFO6ywouPkmNKtkr@yuki>
 <20230504220037.GB4244@pevik>
 <20230504232321.GA25208@pevik>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20230504232321.GA25208@pevik>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi!
Let's get this merged with the sleeps for now and lets try to fix it
properly after the release. You can push the patchset with my Ack.

-- 
Cyril Hrubis
chrubis@suse.cz
