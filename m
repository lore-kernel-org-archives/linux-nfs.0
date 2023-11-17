Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0B7FC54E76
	for <linux-nfs@archiver.kernel.org>; Fri, 17 Nov 2023 02:21:41 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229866AbjKQCVl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 16 Nov 2023 21:21:41 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33194 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229437AbjKQCVl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Nov 2023 21:21:41 -0500
Received: from smtp-out2.suse.de (smtp-out2.suse.de [IPv6:2001:67c:2178:6::1d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E47511A7
        for <linux-nfs@vger.kernel.org>; Thu, 16 Nov 2023 18:21:37 -0800 (PST)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 956181F8C2;
        Fri, 17 Nov 2023 02:21:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1700187696; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
        bh=OsAzFz+9EsCU+/oYO79MjfVBgs8YcJ7Jwn1THYhlST0=;
        b=qE8ejEhsLtKxAYdNGDNt4dc0bKR+vYrT61zekF3M+/AVv/4jI4Sb+yfgOQdXeD5FJvPEGv
        qpTpitlSDUiiuyg6qL+4SnchTVS68huQbjZevKJ6oMnC2ywyW2waFnF9zt11HDXpFJ+0Fs
        y2o/QDTRktLfn5lScH/lTW5QA9/2FzU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1700187696;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
        bh=OsAzFz+9EsCU+/oYO79MjfVBgs8YcJ7Jwn1THYhlST0=;
        b=zY9/tODxbMCu8FrAItczC92wx11jHe/aDZ7fYjbQXWIOjLC2WL2A8kaEIp8gz3IEF2N+fb
        w236jyQRO1skyjAA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 8CC221341F;
        Fri, 17 Nov 2023 02:21:34 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id l5gbES7OVmUREwAAMHmgww
        (envelope-from <neilb@suse.de>); Fri, 17 Nov 2023 02:21:34 +0000
From:   NeilBrown <neilb@suse.de>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>
Cc:     linux-nfs@vger.kernel.org, Olga Kornievskaia <kolga@netapp.com>,
        Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Subject: [PATCH 0/9 v3] support admin-revocation of v4 state
Date:   Fri, 17 Nov 2023 13:18:46 +1100
Message-ID: <20231117022121.23310-1-neilb@suse.de>
X-Mailer: git-send-email 2.42.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Authentication-Results: smtp-out2.suse.de;
        none
X-Spamd-Result: default: False [3.62 / 50.00];
         ARC_NA(0.00)[];
         RCVD_VIA_SMTP_AUTH(0.00)[];
         FROM_HAS_DN(0.00)[];
         TO_DN_SOME(0.00)[];
         R_MISSING_CHARSET(2.50)[];
         TO_MATCH_ENVRCPT_ALL(0.00)[];
         MIME_GOOD(-0.10)[text/plain];
         BROKEN_CONTENT_TYPE(1.50)[];
         RCPT_COUNT_FIVE(0.00)[6];
         NEURAL_HAM_LONG(-1.00)[-1.000];
         DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
         NEURAL_HAM_SHORT(-0.20)[-1.000];
         MID_CONTAINS_FROM(1.00)[];
         FUZZY_BLOCKED(0.00)[rspamd.com];
         FROM_EQ_ENVFROM(0.00)[];
         MIME_TRACE(0.00)[0:+];
         RCVD_COUNT_TWO(0.00)[2];
         RCVD_TLS_ALL(0.00)[];
         BAYES_HAM(-0.08)[63.23%]
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This set adds a prequel series to my previous posting which addresses
some locking problems around ->sc_type and splits that field into
to separate fields: sc_type and sc_status.
The recovation code is modified to accomodate these changed.

Thanks
NeilBrown

 [PATCH 1/9] nfsd: hold ->cl_lock for hash_delegation_locked()
 [PATCH 2/9] nfsd: avoid race after unhash_delegation_locked()
 [PATCH 3/9] nfsd: split sc_status out of sc_type
 [PATCH 4/9] nfsd: prepare for supporting admin-revocation of state
 [PATCH 5/9] nfsd: allow admin-revoked state to appear in
 [PATCH 6/9] nfsd: allow admin-revoked NFSv4.0 state to be freed.
 [PATCH 7/9] nfsd: allow lock state ids to be revoked and then freed
 [PATCH 8/9] nfsd: allow open state ids to be revoked and then freed
 [PATCH 9/9] nfsd: allow delegation state ids to be revoked and then

