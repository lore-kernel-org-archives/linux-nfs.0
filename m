Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8757BC04E69
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Aug 2023 07:35:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232005AbjHBHf2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Aug 2023 03:35:28 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:39834 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231322AbjHBHf0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Aug 2023 03:35:26 -0400
Received: from smtp-out2.suse.de (smtp-out2.suse.de [IPv6:2001:67c:2178:6::1d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 24B0A1BF0
        for <linux-nfs@vger.kernel.org>; Wed,  2 Aug 2023 00:35:01 -0700 (PDT)
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by smtp-out2.suse.de (Postfix) with ESMTPS id BF4E11F891;
        Wed,  2 Aug 2023 07:34:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
        t=1690961698; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
        bh=HyOqO2IPT2+lHt5ryXdoYZXAW3TdtuHLWHrZaY+Oxnc=;
        b=Nuo7/Hwk6LEVOnuEyovN+uMkYazUQ8EE7AbM6CTaIyn1pmDXgWYgCSdXTDq2YUA+zRZuYg
        8x+hWUWth3HeV9ELqiM0eC0TxHXfzT3xVLcA0Ry0dxgW9/NnVEOHfFYYjkMW/vjnfHr2kK
        bwHUGwyC67xataKWAdci4kkSehUBL+Y=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
        s=susede2_ed25519; t=1690961698;
        h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
         mime-version:mime-version:  content-transfer-encoding:content-transfer-encoding;
        bh=HyOqO2IPT2+lHt5ryXdoYZXAW3TdtuHLWHrZaY+Oxnc=;
        b=0Yr9YxPFHdxB3anE5Ho++GleRuy2I5Q4VIEOK1vumhTUR0OI56g5oLo/QDgLm4oqJ76FhW
        cDOXm6jANh1OsLCg==
Received: from imap2.suse-dmz.suse.de (imap2.suse-dmz.suse.de [192.168.254.74])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature ECDSA (P-521) server-digest SHA512)
        (No client certificate requested)
        by imap2.suse-dmz.suse.de (Postfix) with ESMTPS id 7F30013909;
        Wed,  2 Aug 2023 07:34:57 +0000 (UTC)
Received: from dovecot-director2.suse.de ([192.168.254.65])
        by imap2.suse-dmz.suse.de with ESMTPSA
        id jbLCDCEHymTVIwAAMHmgww
        (envelope-from <neilb@suse.de>); Wed, 02 Aug 2023 07:34:57 +0000
From:   NeilBrown <neilb@suse.de>
To:     Chuck Lever <chuck.lever@oracle.com>,
        Jeff Layton <jlayton@kernel.org>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] SUNRPC: thread management improvements
Date:   Wed,  2 Aug 2023 17:34:37 +1000
Message-Id: <20230802073443.17965-1-neilb@suse.de>
X-Mailer: git-send-email 2.40.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Here are some revised patches based on the latest
  topic-sunrpc-thread-scheduling

The refactoring is now a bit tidier

Thanks,
NeilBrown


 [PATCH 1/6] SUNRPC: move all of xprt handling into svc_xprt_handle()
 [PATCH 2/6] SUNRPC: rename and refactor svc_get_next_xprt()
 [PATCH 3/6] SUNRPC: integrate back-channel processing with svc_recv()
 [PATCH 4/6] SUNRPC: change how svc threads are asked to exit.
 [PATCH 5/6] SUNRPC: add list of idle threads
 [PATCH 6/6] SUNRPC: discard SP_CONGESTED

