Return-Path: <SRS0=HPA/=RI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83D34C00319
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 13:35:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 53C2F206DD
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Mar 2019 13:35:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551792945;
	bh=DarZh8URDc3RN1nwgBSkqOBxMjH9BgDUbSjAuqJ5w1g=;
	h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:List-ID:
	 From;
	b=STy094mt7Kgit6G9M88N8wgPFdoxQFuFPew2qBDjl3mqMab4sdxol1GRNZN1q0IWv
	 6KmVuSPlZO1hJgm8PshMm79SjLzXp6u0SHbUGLgYpXCSbpG5/h2OBes6wAJPL/wxOH
	 pJBe/tbwB5O6RrBXBYZNQ/D69Qza1MkzT3dk6C8E=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727950AbfCENfo (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Mar 2019 08:35:44 -0500
Received: from mail.kernel.org ([198.145.29.99]:54646 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727492AbfCENfo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Mar 2019 08:35:44 -0500
Received: from localhost (unknown [23.100.24.84])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 5B755206DD;
        Tue,  5 Mar 2019 13:35:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1551792943;
        bh=DarZh8URDc3RN1nwgBSkqOBxMjH9BgDUbSjAuqJ5w1g=;
        h=Date:From:To:To:To:Cc:Cc:Subject:In-Reply-To:References:From;
        b=CekkSQf+8eYkoTOSUwnAFkV5OceREZTvmfhiPXbRqggKBA0ClCweG/jvk8n9xjHQq
         lH/KSZhosZpDIx2QizXcjMjOZyokeZ9wPjVy12no222LXBO9NgFZP5nA3JelJ8bCTx
         t8acZmLxxX/uB2OdWYq5T7fzkg1/Zb5Nu0YD4n14=
Date:   Tue, 05 Mar 2019 13:35:42 +0000
From:   Sasha Levin <sashal@kernel.org>
To:     Sasha Levin <sashal@kernel.org>
To:     Trond Myklebust <trondmy@gmail.com>
To:     linux-nfs@vger.kernel.org
Cc:     stable@vger.kernel.org
Cc:     stable@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSv4.1: Reinitialise sequence results before retransmitting a request
In-Reply-To: <20190301191153.104498-1-trond.myklebust@hammerspace.com>
References: <20190301191153.104498-1-trond.myklebust@hammerspace.com>
Message-Id: <20190305133543.5B755206DD@mail.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v4.20.13, v4.19.26, v4.14.104, v4.9.161, v4.4.176, v3.18.136.

v4.20.13: Build OK!
v4.19.26: Build OK!
v4.14.104: Build OK!
v4.9.161: Failed to apply! Possible dependencies:
    172d9de15a0d ("NFS: Change nfs4_get_session() to take an nfs_client structure")
    3be0f80b5fe9 ("NFSv4.1: Fix up replays of interrupted requests")
    42e1cca7e91e ("NFS: Change nfs4_setup_sequence() to take an nfs_client structure")
    6de7e12f53a1 ("NFS: Use nfs4_setup_sequence() everywhere")
    7981c8a65914 ("NFS: Create a single nfs4_setup_sequence() function")
    efc6f4aa742d ("NFS: Move nfs4_get_session() into nfs4_session.h")

v4.4.176: Failed to apply! Possible dependencies:
    172d9de15a0d ("NFS: Change nfs4_get_session() to take an nfs_client structure")
    3be0f80b5fe9 ("NFSv4.1: Fix up replays of interrupted requests")
    42e1cca7e91e ("NFS: Change nfs4_setup_sequence() to take an nfs_client structure")
    5f83d86cf531 ("NFSv4.x: Fix wraparound issues when validing the callback sequence id")
    68d264cf02b0 ("NFS42: handle layoutstats stateid error")
    6de7e12f53a1 ("NFS: Use nfs4_setup_sequence() everywhere")
    80f9642724af ("NFSv4.x: Enforce the ca_maxresponsesize_cached on the back channel")
    810d82e68301 ("NFSv4.x: Allow multiple callbacks in flight")
    9a0fe86745b8 ("pNFS: Handle NFS4ERR_OLD_STATEID correctly in LAYOUTSTAT calls")
    efc6f4aa742d ("NFS: Move nfs4_get_session() into nfs4_session.h")
    f74a834a0e1b ("NFSv4.x: CB_SEQUENCE should return NFS4ERR_DELAY if still executing")

v3.18.136: Failed to apply! Possible dependencies:
    193e3aa2ccfb ("nfs41: introduce NFS_LAYOUT_RETURN_BEFORE_CLOSE")
    3be0f80b5fe9 ("NFSv4.1: Fix up replays of interrupted requests")
    4579d6b897ee ("nfs41: pass iomode through layoutreturn args")
    6de7e12f53a1 ("NFS: Use nfs4_setup_sequence() everywhere")
    9bf87482ddc6 ("nfs41: serialize first layoutget of a file")
    aa8a45ee974d ("nfs41: wait for LAYOUTRETURN before retrying LAYOUTGET")
    abcb7bfc9fde ("pNFS/flexfiles: add layoutstats tracking")
    c829013dca33 ("nfs41: add NFS_LAYOUT_RETRY_LAYOUTGET to layout header flags")
    ce6ab4f238cb ("nfs41: don't use a layout if it is marked for returning")
    d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
    e736a5b98c7a ("nfs41: clear NFS_LAYOUT_RETURN if layoutreturn is sent or failed to send")
    f40eb5d044e2 ("nfs41: make a helper function to send layoutreturn")


How should we proceed with this patch?

--
Thanks,
Sasha
