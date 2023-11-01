Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3710C4332F
	for <linux-nfs@archiver.kernel.org>; Wed,  1 Nov 2023 01:01:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1347108AbjKABBF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 31 Oct 2023 21:01:05 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55478 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1345029AbjKABBE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Oct 2023 21:01:04 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [IPv6:2001:67c:2178:6::1d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5262FEA
        for <linux-nfs@vger.kernel.org>; Tue, 31 Oct 2023 18:00:59 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id 022BA1F460;
        Wed,  1 Nov 2023 01:00:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1698800458; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
        bh=F+8Z8VOsneUl4jIvXbfhZSjbowBbSCHftNbYyjK0TKI=;
        b=XBquXQ+D1faEMOCNMgW2IWX2IW7E2WaIwGnQBHEEh1Lj3dj+LDuGgN5Y1ivwYOAmoEzbBP
        9euXiL0DBSdcqRkYLhPb2/csk3Ow/vkg0+VHf5KWJWtWzcIJXVAb8QuserOyws8IlMJEre
        zIhKLz0LNHBgOnA6WIOv7swFbRtTTGw=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1698800458;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
        bh=F+8Z8VOsneUl4jIvXbfhZSjbowBbSCHftNbYyjK0TKI=;
        b=8ePUee8SYe6XTKhtMmkUcxuTaJG72G7hV7Ce2uwcLsqPWSW6dkJqWTIPIrTjXGJFVqEhMX
        BX1EaYQs9zX8twDA==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id EF47B138EF;
        Wed,  1 Nov 2023 01:00:55 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id YNZPKUejQWXlOgAAMHmgww
        (envelope-from <neilb@suse.de>); Wed, 01 Nov 2023 01:00:55 +0000
From:   NeilBrown <neilb@suse.de>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>
Cc:     linux-nfs@vger.kernel.org, Olga Kornievskaia <kolga@netapp.com>,
        Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Subject: [PATCH 0/6 v2] support admin-revocation of v4 state
Date:   Wed,  1 Nov 2023 11:57:07 +1100
Message-ID: <20231101010049.27315-1-neilb@suse.de>
X-Mailer: git-send-email 2.42.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This set fixes two issues found by kernel test robot
1/ nfsd4_revoke_states() needs to be defined when not CONFIG_NFSD_V4
2/ nfs40_last_revoke is larger than a mechine word in 32 bit configs,
   so needs protection - use nn->client_lock which is already taken when
   nfs40_last_revoke is accessed.

NeilBrown



