Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A84CDC07545
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Oct 2023 14:02:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S234664AbjJXOCE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 24 Oct 2023 10:02:04 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50576 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234582AbjJXOCD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Oct 2023 10:02:03 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 10999110
        for <linux-nfs@vger.kernel.org>; Tue, 24 Oct 2023 07:01:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1698156080;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=xWzuQlELGbL+gCIg4u/+SkfNkN3ZnZ0/znjFII22yfs=;
        b=DQlo+nzfv2GCqQlKPbe8d6+oRUm3jJagBKFWoAVXOOP8nA8z3++qp2vEm4ab8XpqisJUyP
        GW1tO9RBnz3nUEW/1NKK+ln8a+2IP87YogpuXtZrOR8dl72AFKLuErivVERuxMJQVgUF78
        twUr5kZdXaN534ME8nHK7nh0kgIOnk4=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-483-ce_wB_DZMKCIlrTetlG3ow-1; Tue, 24 Oct 2023 10:01:11 -0400
X-MC-Unique: ce_wB_DZMKCIlrTetlG3ow-1
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
        (No client certificate requested)
        by mimecast-mx02.redhat.com (Postfix) with ESMTPS id BBD5D918571;
        Tue, 24 Oct 2023 14:01:10 +0000 (UTC)
Received: from [100.85.132.103] (unknown [10.22.48.7])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 176F92026D4C;
        Tue, 24 Oct 2023 14:01:08 +0000 (UTC)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     Amir Goldstein <amir73il@gmail.com>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna@kernel.org>,
        Jeff Layton <jlayton@kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>,
        Christian Brauner <brauner@kernel.org>,
        Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: derive f_fsid from server's fsid
Date:   Tue, 24 Oct 2023 10:01:07 -0400
Message-ID: <1CFE0178-CE91-4C99-B43E-33EF78D0BEBF@redhat.com>
In-Reply-To: <20231024110109.3007794-1-amir73il@gmail.com>
References: <20231024110109.3007794-1-amir73il@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.4
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 24 Oct 2023, at 7:01, Amir Goldstein wrote:

> Fold the server's 128bit fsid to report f_fsid in statfs(2).
> This is similar to how uuid is folded for f_fsid of ext2/ext4/zonefs.
>
> This allows nfs client to be monitored by fanotify filesystem watch
> for local client access if nfs supports re-export.
>
> For example, with inotify-tools 4.23.8.0, the following command can be
> used to watch local client access over entire nfs filesystem:
>
>   fsnotifywatch --filesystem /mnt/nfs
>
> Note that fanotify filesystem watch does not report remote changes on
> server.  It provides the same notifications as inotify, but it watches
> over the entire filesystem and reports file handle of objects and fsid
> with events.

I think this will run into trouble where an NFSv4 will report both
fsid.major and fsid.minor as zero for the special root filesystem.   We can
expect an NFSv4 client to have one of these per server.

Could use s_dev from nfs_server for a unique major/minor for each mount on
the client, but these values won't be stable against a particular server
export.

Ben

