Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74FE9C77B7C
	for <linux-nfs@archiver.kernel.org>; Thu,  4 May 2023 21:16:42 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229651AbjEDVQk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 May 2023 17:16:40 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49278 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229588AbjEDVQj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2023 17:16:39 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3E6ED11D98
        for <linux-nfs@vger.kernel.org>; Thu,  4 May 2023 14:16:38 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id D21B73371B;
        Thu,  4 May 2023 21:16:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1683234996;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=b+s1XV4cSiudXwWR6T6pIAjl/DxHODUa6ZJRBdF70UY=;
        b=ytII4toP7dcPoX6zFf2MnXrtAWf2B0N3hf9/tPKEUHXhq6Xr76w25cfwUmJLWbJ8cbeNuW
        LGZq4iKX2zhghMYMBQap7c/lkrDU1t5vgU50O4TONfBTK74mD/vDOejGOVbNjjmpEKOuH6
        /thxusxNuz2x+bhJd4tR6h9v/NGaz38=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1683234996;
        h=from:from:reply-to:reply-to:date:date:message-id:message-id:to:to:
         cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=b+s1XV4cSiudXwWR6T6pIAjl/DxHODUa6ZJRBdF70UY=;
        b=mBJAoPTL6NIQHMEL07CC9HbNyYYb7I27IP8lVyQKrK1SEYsEtAOMt6YuBvoylTassPlnbc
        i30QvyZsCtjkONBA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 6D30F133F7;
        Thu,  4 May 2023 21:16:36 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id FfjdF7QgVGRVOwAAMHmgww
        (envelope-from <pvorel@suse.cz>); Thu, 04 May 2023 21:16:36 +0000
Date:   Thu, 4 May 2023 23:16:34 +0200
From:   Petr Vorel <pvorel@suse.cz>
To:     Cyril Hrubis <chrubis@suse.cz>
Cc:     ltp@lists.linux.it, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH v5 1/5] nfs_lib.sh: Cleanup local and remote directories
 setup
Message-ID: <20230504211634.GA4244@pevik>
Reply-To: Petr Vorel <pvorel@suse.cz>
References: <20230504131414.3826283-1-pvorel@suse.cz>
 <20230504131414.3826283-2-pvorel@suse.cz>
 <ZFO597l50v9PEQPP@yuki>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ZFO597l50v9PEQPP@yuki>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Cyril,

...
> > +# directory mounted by NFS client
> > +get_local_dir()
> > +{
> > +	local v="$1"
> > +	local n="$2"
> > +
> > +	echo "$TST_TMPDIR/$v/$n"
> > +}
> > +
> > +# directory on NFS server
> > +get_remote_dir()
> > +{
> > +	local v="$1"
> > +	local n="$2"
> > +
> > +	echo "$TST_TMPDIR/$v/$n"
> > +}

> It's a bit puzzling why we have two identical functions with a different
> name...

It's a preparation for TST_ALL_FILESYSTEMS=1 where the location changes.
I can squash this into that commit where it changes.

Kind regards,
Petr
