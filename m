Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F375EB64DC
	for <linux-nfs@archiver.kernel.org>; Sun,  9 Jul 2023 20:04:57 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229481AbjGIUE4 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 9 Jul 2023 16:04:56 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51830 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229441AbjGIUEz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Jul 2023 16:04:55 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1BB88FE
        for <linux-nfs@vger.kernel.org>; Sun,  9 Jul 2023 13:04:55 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 9D57860C2D
        for <linux-nfs@vger.kernel.org>; Sun,  9 Jul 2023 20:04:54 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD663C433C7;
        Sun,  9 Jul 2023 20:04:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1688933093;
        bh=iI3eT2ljcPjepXDv1QojtHWoc+EcGPmWvmwVPggOY90=;
        h=Subject:From:To:Cc:Date:From;
        b=srjrCR1gAXlSlJdQgv+QutBgJyVENnXJeakCj/okPk41OF/gtokN7fGROmEc4gFLC
         OzkTOpULFDvCf3Dgm+h/OXaWfjAyWzvAq1AAxZnRD1y0C4mPr0XJjgJfctOuxc1WG5
         vFpSZtXIZi2JOmGGsEhB4ksmOfuu9v5oQqTMb4ikpo67zvkcfGLJJInYe5izbsG3Il
         jRH1xyEzr1IqjlmiXQo07ltaSpe1hqYRT4TyEEfO/fzhhDHlz4QprVQCbRGY8ZSF5z
         cwC4k+6XAZe0ejUhqAPvOz4by3GOhpL59lYQ44JNBrIxFxVH5o0hxc2n7HxN5IQm5j
         mPQF3VQib5TKw==
Subject: [PATCH RFC 0/4] Send RPC-on-TCP with one sock_sendmsg() call
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>,
        David Howells <dhowells@redhat.com>, dhowells@redhat.com
Date:   Sun, 09 Jul 2023 16:04:52 -0400
Message-ID: <168893265677.1949.1632048925203798962.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After some discussion with David Howells at LSF/MM 2023, we arrived
at a plan to use a single sock_sendmsg() call for transmitting an
RPC message on socket-based transports. This is an initial part of
the transition to support handling folios with file content, but it
has scalability benefits as well.

Comments, suggestions, and test results are welcome.

---

Chuck Lever (4):
      SUNRPC: Convert svc_tcp_sendmsg to use bio_vecs directly
      SUNRPC: Convert svc_udp_sendto() to use the per-socket bio_vec array
      SUNRPC: Use a per-transport receive bio_vec array
      SUNRPC: Send RPC message on TCP with a single sock_sendmsg() call


 include/linux/sunrpc/svc.h     |   1 -
 include/linux/sunrpc/svcsock.h |   7 ++
 net/sunrpc/svcsock.c           | 142 ++++++++++++++++++---------------
 3 files changed, 86 insertions(+), 64 deletions(-)

--
Chuck Lever

