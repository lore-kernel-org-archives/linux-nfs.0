Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD567C433EF
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Jul 2022 01:29:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230401AbiGGB3T (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Jul 2022 21:29:19 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60964 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229869AbiGGB3S (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2022 21:29:18 -0400
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DC5A22E6AF
        for <linux-nfs@vger.kernel.org>; Wed,  6 Jul 2022 18:29:17 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id 970B322197;
        Thu,  7 Jul 2022 01:29:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1657157356; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=Qtsm/K1h5PZBqZjmrEGM5MtAPPcdGp/Snt0jKIWeJ/Y=;
        b=mX54W19gxP9XQ4/tSD1CxIfHar0XP7PXycvCaRAmjPEVetHCo9Gdk8jMd6z7SLklDfxWOZ
        CO3VJRUpDisv11aKjx42mpyQA6/65Q06linF197cjXJW3n9ditxhwUndOGdcVtciM4ocVL
        /hmTOt7DMGP5ciPEET8n1koSM2BlgtA=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1657157356;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=Qtsm/K1h5PZBqZjmrEGM5MtAPPcdGp/Snt0jKIWeJ/Y=;
        b=V8cmemxOzERFQRPBvknYbAf5S5qIODpo7/CYqF39XBOZJNTkLjq9rKJp75yYhwlW/nG42p
        omnsuwN9njxHtFBQ==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 70BFA13A7D;
        Thu,  7 Jul 2022 01:29:15 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id zK/QCus2xmIGYAAAMHmgww
        (envelope-from <neilb@suse.de>); Thu, 07 Jul 2022 01:29:15 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Chuck Lever III" <chuck.lever@oracle.com>
Cc:     "Jeff Layton" <jlayton@kernel.org>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/8] NFSD: reduce locking in nfsd_lookup()
In-reply-to: <0A6DEF8A-232B-45FE-8A45-C403DE4E4342@oracle.com>
References: <165708033167.1940.3364591321728458949.stgit@noble.brown>,
 <165708109258.1940.1095066282860556838.stgit@noble.brown>,
 <0A6DEF8A-232B-45FE-8A45-C403DE4E4342@oracle.com>
Date:   Thu, 07 Jul 2022 11:29:09 +1000
Message-id: <165715734903.17141.8779762171235676843@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, 07 Jul 2022, Chuck Lever III wrote:
> > +		/* We want to keep the directory locked until we've had a chance
> > +		 * to acquire a delegation if appropriate, so request that
> > +		 * nfsd_lookup() hold on to the lock.
> > 		 */
> > 		status = nfsd_lookup(rqstp, current_fh,
> > -				     open->op_fname, open->op_fnamelen, *resfh);
> > +				     open->op_fname, open->op_fnamelen, *resfh,
> > +				     true);
> > +		if (!status) {
> > +			/* NFSv4 protocol requires change attributes even though
> > +			 * no change happened.
> > +			 */
> > +			fh_fill_pre_attrs(current_fh);
> > +			fh_fill_post_attrs(current_fh);
> 
> If this is really correct, the comment should also state that
> no concurrent changes to the parent are possible during
> the lookup, and thus the pre and post attributes are expected
> to be the same always.

The earlier comment notes that nfsd_lookup() is called in a way in which
it takes and keeps the lock - that should imply that no other changes
can happen.  But with such insane looking code, it doesn't hurt to be
extra explicit.

> 
> Otherwise, this code paragraph looks just a little insane ;-)
> 
:-)

Thanks,
NeilBrown
