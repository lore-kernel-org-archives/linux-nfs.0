Return-Path: <SRS0=SM4e=3O=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5818C2D0CE
	for <linux-nfs@archiver.kernel.org>; Sat, 25 Jan 2020 01:33:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AA3872072C
	for <linux-nfs@archiver.kernel.org>; Sat, 25 Jan 2020 01:33:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="RxXKHKet"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729327AbgAYBda (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 24 Jan 2020 20:33:30 -0500
Received: from us-smtp-1.mimecast.com ([205.139.110.61]:24907 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1729195AbgAYBda (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2020 20:33:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1579916009;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=DsoG39HRF5SQvq7A5XxsjCWxy62CkNT6AERFH6K0DbA=;
        b=RxXKHKetZsRdzj3V7JhQ8pFzNdsmcszfyGue555myzZv0rNXIgiNKA386ZZDAU2nxPTrO7
        JIXSTVa9W+UF7Ktj2BjqEf319wkEZzRgsN66Jr9K3urZKW9sNRFjEPa0T5WCNdnjc7vQwp
        Asa4BTO9XQigE46jIqaaEZNDlMeY+cs=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-42-iCOxGx4NPnKkNba6A8zr-g-1; Fri, 24 Jan 2020 20:33:27 -0500
X-MC-Unique: iCOxGx4NPnKkNba6A8zr-g-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 674C7100550E;
        Sat, 25 Jan 2020 01:33:26 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-64-2.rdu2.redhat.com [10.10.64.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 9B4E660BE1;
        Sat, 25 Jan 2020 01:33:25 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Trond Myklebust" <trondmy@hammerspace.com>
Cc:     Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Revalidate once when holding a delegation
Date:   Fri, 24 Jan 2020 20:33:23 -0500
Message-ID: <43817735-6694-406C-A66A-485A716C7FC5@redhat.com>
In-Reply-To: <ab9d72c908d5c3cecc53ec049572a7675ad12072.camel@hammerspace.com>
References: <c65905b1e2fdaddc6271cbf510d7e30c8790de63.1579874894.git.bcodding@redhat.com>
 <ab9d72c908d5c3cecc53ec049572a7675ad12072.camel@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On 24 Jan 2020, at 14:24, Trond Myklebust wrote:

> On Fri, 2020-01-24 at 09:09 -0500, Benjamin Coddington wrote:
>
> This patch needs to fix nfs_force_lookup_revalidate() to avoid the
> value NFS_DELEGATION_VERF.

I don't understand why.  Doesn't nfs_force_lookup_revalidate() just bump the
directory's cache_change_attribute, which is value we don't care about at
all here.  This patch just sets a magic value on the dentry's d_time after a
revalidation occurs for that dentry while holding a delegation.  It doesn't
care at all about the directory's change_attr.

What am I missing?

Ben

