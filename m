Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5777BC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:51:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 016A5204FD
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:51:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="nfDa2m0T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 016A5204FD
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727655AbeJ3Ckz (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:40:55 -0400
Received: from bombadil.infradead.org ([198.137.202.133]:45472 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727520AbeJ3Ckz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:40:55 -0400
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
        d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
        :References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
        Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
        Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
        List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
         bh=UIKAeBJMk31VCw5MzKhVJn+gsKpR1U0em9/mIPAjnHs=; b=nfDa2m0THrxttbp9jG5A7Zim7
        3ZhGzuEfc80qT6LhUr0DxUHbO1kmpiKEW1DFHX6YQhEgOfqvhBgEiTif7SjaiONfP2ZREII3B39bA
        TqSJuXUfli/EH/zhEK0JgoUOepkCmm1QtKBvAmiXj70vjWz1cXa93jbNE3V2A2CAQ0ePYjWpcuevz
        Z1BKv14XuN9rvogL1t8DDJ5LeI+Bc3xZjoCWmn5T7Wb7w13Y9KyKLn/Pe/djFxtfu7PRYysQZiR09
        lDLvtHYLAffLmtfotQTIVTu0UdoLcmkHMsvQzWrgFBc1j29RODPvz94Wp7LG6kRBf7xRgvgFnkhDm
        JvNCg6C8w==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
        id 1gHBh4-0000AO-Hy; Mon, 29 Oct 2018 17:51:14 +0000
Date:   Mon, 29 Oct 2018 10:51:14 -0700
From:   Matthew Wilcox <willy@infradead.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v5 12/12] NFS: replace cross device check in
 copy_file_range
Message-ID: <20181029175114.GJ28520@bombadil.infradead.org>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
 <20181029174059.38326-14-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181029174059.38326-14-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Oct 29, 2018 at 01:40:59PM -0400, Olga Kornievskaia wrote:
> +	c_in = (NFS_SERVER(file_inode(file_in)))->nfs_client;

Seems to be an unnecessary pair of brackets there, given existing code:

fs/nfs/delegation.c:    struct nfs_client *clp = NFS_SERVER(inode)->nfs_client;
fs/nfs/dir.c:                                     NFS_SERVER(inode)->dtsize, desc->plus);
fs/nfs/file.c:  if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FCNTL)
(etc)

> +	if (c_in->cl_minorversion < 2)

in fact, can't you make this even simpler ...

	if (NFS_SERVER(inode)->nfs_client->cl_minorversion < 2)

I thought you needed to cast it, but code like this:

fs/nfs/nfs4proc.c: NFS_SERVER(dir)->nfs_client->cl_hostname);

would indicate not.
