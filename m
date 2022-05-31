Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3334C433EF
	for <linux-nfs@archiver.kernel.org>; Tue, 31 May 2022 13:25:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1344635AbiEaNZf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 31 May 2022 09:25:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48948 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S236113AbiEaNZe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 May 2022 09:25:34 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.220.29])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9327E62A2F
        for <linux-nfs@vger.kernel.org>; Tue, 31 May 2022 06:25:33 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 46CDD1F99E;
        Tue, 31 May 2022 13:25:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.cz; s=susede2_rsa;
        t=1654003532; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=obQ3N0DdkHxGwCFUhm0D5e+Q51CAJD/HLjUhl5erWvo=;
        b=1+WL0pGv53NbpPfGPXhHTUp+nQiZf5kTSKhewv3EOo6lzeE7UOBWnkdyQcEvDTm3ULDNsJ
        uwYf2fZfhPzTuNDYJ6fWSD1QmW4prg6An8jas6EXGal8NTeBokt5ANcNh67m4IQo1SicWN
        eV1pJ8IcqcjzDzKi0y4TEHRfYhTrtVg=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.cz;
        s=susede2_ed25519; t=1654003532;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=obQ3N0DdkHxGwCFUhm0D5e+Q51CAJD/HLjUhl5erWvo=;
        b=ESmwQOSNVg9C9EXPYELZ1m/kZJbCEPrgBMGJH2D+tBuEB0DyoxYysoz1gSNnoRVD9XuV1B
        DtPJH7yDzPLkFuDw==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 2F51713AA2;
        Tue, 31 May 2022 13:25:32 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id zXPgCUwXlmIxDgAAMHmgww
        (envelope-from <chrubis@suse.cz>); Tue, 31 May 2022 13:25:32 +0000
Date:   Tue, 31 May 2022 15:27:37 +0200
From:   Cyril Hrubis <chrubis@suse.cz>
To:     Petr Vorel <pvorel@suse.cz>
Cc:     ltp@lists.linux.it, Steve Dickson <steved@redhat.com>,
        libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
        automated-testing@yoctoproject.org, Li Wang <liwang@redhat.com>,
        Jan Stancek <jstancek@redhat.com>,
        Yang Xu <xuyang2018.jy@fujitsu.com>,
        Anders Roxell <anders.roxell@linaro.org>,
        Naresh Kamboju <naresh.kamboju@linaro.org>,
        Daniel D??az <daniel.diaz@linaro.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Veronika Kabatova <vkabatov@redhat.com>,
        Alexey Kodanev <aleksei.kodanev@bell-sw.com>
Subject: Re: [RFC PATCH 0/3] Remove RPC rup and rusers tests
Message-ID: <YpYXyb4jyx0zV2Vg@yuki>
References: <20220428144308.32639-1-pvorel@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20220428144308.32639-1-pvorel@suse.cz>
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi!
Patchset pushed, thanks.

-- 
Cyril Hrubis
chrubis@suse.cz
