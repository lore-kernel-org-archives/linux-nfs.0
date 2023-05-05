Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21083C77B7C
	for <linux-nfs@archiver.kernel.org>; Fri,  5 May 2023 10:44:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231577AbjEEKol (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 May 2023 06:44:41 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47150 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230411AbjEEKol (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 5 May 2023 06:44:41 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.220.29])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5B72BE41
        for <linux-nfs@vger.kernel.org>; Fri,  5 May 2023 03:44:40 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 1020C1F8C1;
        Fri,  5 May 2023 10:44:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1683283479;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=5mcKZoU9sFVN/fiGmifVNNWu7VXyrMMMjFsjIqNI7M0=;
        b=V/lgxkh71tCBx8d3VztqKsVW+DAbzVyutGyv3pKTXT2SsCj49g0hOHPvRkzODw3l6g/O43
        CqMaSeDOiRgSi1yZkxaLkSECsefjY0r3SkDMNpEpRknzdw4gyUulX3U+C7HLcSk7SZAC09
        +s2DzkmDjWI4BfFUSzVyJdDcr4q9W+0=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1683283479;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=5mcKZoU9sFVN/fiGmifVNNWu7VXyrMMMjFsjIqNI7M0=;
        b=W/wRj+Kw6VsTxZWh4QehT+gp8LgsgwEAjP1bU3vo/vmqGqmjBjyMeBhL+3+y1I5f2/mQ2F
        gYYnyLCJRzXAdvCw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 53E7F13513;
        Fri,  5 May 2023 10:44:38 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id 8/lRDRbeVGRWAgAAMHmgww
        (envelope-from <pvorel@suse.cz>); Fri, 05 May 2023 10:44:38 +0000
Date:   Fri, 5 May 2023 12:44:36 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     Cyril Hrubis <chrubis@suse.cz>
Cc:     ltp@lists.linux.it, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH v5 1/5] nfs_lib.sh: Cleanup local and remote directories
 setup
Message-ID: <20230505104436.GA31237@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20230504131414.3826283-1-pvorel@suse.cz>
 <20230504131414.3826283-2-pvorel@suse.cz>
 <ZFO597l50v9PEQPP@yuki>
 <20230504211634.GA4244@pevik>
 <ZFTdp3wAO4qbpUjS@yuki>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ZFTdp3wAO4qbpUjS@yuki>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Cyril,

> Hi!
> > > It's a bit puzzling why we have two identical functions with a different
> > > name...

> > It's a preparation for TST_ALL_FILESYSTEMS=1 where the location changes.
> > I can squash this into that commit where it changes.

> That is the missing bit. No need to squash maybe just note that the
> directory will change in the last commit of the patchset.

+1 (I intended and obviously forgot).

Kind regards,
Petr
