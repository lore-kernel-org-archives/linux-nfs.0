Return-Path: <SRS0=YoU0=D2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2093AC433DF
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Oct 2020 17:55:51 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B4709222EA
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Oct 2020 17:55:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1603130150;
	bh=/Ou1201yhdUNXE/9uX43V7eOsDH00j0nbAO5iwPaJcM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=uvrZsUmHKGC6bTjq0a5BjSL6Yh2wFzbmYuB/Jnm3ooh51cN4PlQeIyU7wpQJBRUTh
	 nbzK6K88lhOcRl2Geoms0X6C1FZk1QvvCch1POS3I3rztcfwWgW2brFIDqoQH3TMDc
	 ykAKNZpe2gY1AGHR5GCaAoule1a7KGtsUDFLBGB4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727962AbgJSRzu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Oct 2020 13:55:50 -0400
Received: from mail.kernel.org ([198.145.29.99]:52404 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726005AbgJSRzu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Oct 2020 13:55:50 -0400
Received: from localhost.localdomain (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 2ED892224D;
        Mon, 19 Oct 2020 17:55:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1603130149;
        bh=/Ou1201yhdUNXE/9uX43V7eOsDH00j0nbAO5iwPaJcM=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=awN0nMzS8w62V6gsSqWxYb5I+wQRwuWELtFptcN9b7Q3/ZrLQxnr+oizjBA9h61h/
         ntw/5GbOmCMcokKjDV4Pn09LP8ybYqjFC3J1ZP2nIHhFascLA1UOCDNbKWM1dWRTZ6
         BcWJl6QwTKkmC89ZLERYBKQNKlDjVFZnhAaDeAUI=
From:   trondmy@kernel.org
To:     Daire Byrne <daire@dneg.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Add NFSv3 emulation of the lookupp operation
Date:   Mon, 19 Oct 2020 13:53:28 -0400
Message-Id: <20201019175330.595894-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <279389889.68934777.1603124383614.JavaMail.zimbra@dneg.com>
References: <279389889.68934777.1603124383614.JavaMail.zimbra@dneg.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

In order to use the open-by-filehandle functionality with NFSv3, we
need to ensure that the NFS client can convert disconnected dentries
into connected ones by doing a reverse walk of the filesystem path.
To do so, NFSv4 provides the LOOKUPP operation, which does not
exist in NFSv3, but which can usually be emulated using lookup("..").

Trond Myklebust (2):
  NFSv3: Refactor nfs3_proc_lookup() to split out the dentry
  NFSv3: Add emulation of the lookupp() operation

 fs/nfs/nfs3proc.c | 43 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 32 insertions(+), 11 deletions(-)

-- 
2.26.2

