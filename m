Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97D76C433F5
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Feb 2022 01:59:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235393AbiBHB7u (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 7 Feb 2022 20:59:50 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46490 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230489AbiBHB7u (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Feb 2022 20:59:50 -0500
Received: from smtp-out1.suse.de (smtp-out1.suse.de [195.135.220.28])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 4101CC061355
        for <linux-nfs@vger.kernel.org>; Mon,  7 Feb 2022 17:59:49 -0800 (PST)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out1.suse.de (Postfix) with ESMTPS id BB39B210E9;
        Tue,  8 Feb 2022 01:59:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1644285587; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=QcGgrQSmVUQJUmkNSf3OWYjL1dix04JBmnpiDqBdSOc=;
        b=kCIQTDmmB/zugna9lkEWr/yzba1mmwQfPHcdPoLTv23zAA1JwAPNnPSAEseRbuyJlZ/+Cx
        c1rWEThyi4is5myepHBwMk36GvCKv38Jy8JSSLSLFBpZqP0XUpeePRvA8xSma+OP01sRbT
        evBABfztIHFSeRulFDG5usX/n9SeQV4=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1644285587;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=QcGgrQSmVUQJUmkNSf3OWYjL1dix04JBmnpiDqBdSOc=;
        b=nmRrx73xIAmk8w5KP8lzAmqwqr/ARJaJgLMTKFYu5b8bMBqJX3jA0c8weBXMXiCwfSZTkN
        4ZHb0ySxTvhnSWBQ==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 655FB12FC5;
        Tue,  8 Feb 2022 01:59:44 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id YBrPCJDOAWLNSAAAMHmgww
        (envelope-from <neilb@suse.de>); Tue, 08 Feb 2022 01:59:44 +0000
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From:   "NeilBrown" <neilb@suse.de>
To:     "Benjamin Coddington" <bcodding@redhat.com>
Cc:     "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: v4 clientid uniquifiers in containers/namespaces
In-reply-to: <6CEC5101-0512-4082-81F8-BDFEC5B6DF3A@redhat.com>
References: <6CEC5101-0512-4082-81F8-BDFEC5B6DF3A@redhat.com>
Date:   Tue, 08 Feb 2022 12:59:38 +1100
Message-id: <164428557862.27779.17375354328525752842@noble.neil.brown.name>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Sun, 06 Feb 2022, Benjamin Coddington wrote:
> Hi all,
> 
> Is anyone using a udev(-like) implementation with NETLINK_LISTEN_ALL_NSID?
> It looks like that is at least necessary to allow the init namespaced udev
> to receive notifications on /sys/fs/nfs/net/nfs_client/identifier, which
> would be a pre-req to automatically uniquify in containers.

Could you walk me through the reasoning here - or point me to where it
has been discussed.
It seems to me that mount.nfs is the place to set nfs_client/identifier.
It can be told (via /etc/nfs.conf or /etc/nfsmount.conf) how to generate
and where to store the identifier.  It can check the current value and
update if needed.  As long as the identifier is set before the first
mount, there is no rush.

Why does it need to be done in response to a uevent??

Thanks,
NeilBrown
