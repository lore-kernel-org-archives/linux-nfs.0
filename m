Return-Path: <SRS0=DoCl=EJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2282C2D0A3
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Nov 2020 11:14:14 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 450C3223BD
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Nov 2020 11:14:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="aFDg+/7s"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727895AbgKCLON (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Nov 2020 06:14:13 -0500
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:22582 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725988AbgKCLOM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Nov 2020 06:14:12 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1604402052;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         in-reply-to:in-reply-to:references:references;
        bh=bpeJUUUm+UN+vA/vHszrfaNeho9kV2bjOYN1pQPexEA=;
        b=aFDg+/7sgPI0lRnMdRxEB2gwKH4GjljKR8jh07A6m1Asjn5tNZSFFTlOfbKspIcyq/RAKC
        1jrM3FpV61vn0y1rFGY8dkiSS5wOa5KFSFyZCJUmmKbKDCeXVvk2DXSEjgfJ/PNDDgj8uX
        1ayGvVtTOCdujQa382GUuNaLowp0JIM=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-291-o_HoLYWUPHuVqh5vaU30LA-1; Tue, 03 Nov 2020 06:14:09 -0500
X-MC-Unique: o_HoLYWUPHuVqh5vaU30LA-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 563961009E28;
        Tue,  3 Nov 2020 11:14:08 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-64-2.rdu2.redhat.com [10.10.64.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 1A1D2805D5;
        Tue,  3 Nov 2020 11:14:08 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     trondmy@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] NFS: Remove unnecessary inode lock in nfs_fsync_dir()
Date:   Tue, 03 Nov 2020 06:14:07 -0500
Message-ID: <278531B6-6573-4CCB-9B9F-123451635C47@redhat.com>
In-Reply-To: <20201030215730.85147-2-trondmy@kernel.org>
References: <20201030215730.85147-1-trondmy@kernel.org>
 <20201030215730.85147-2-trondmy@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 30 Oct 2020, at 17:57, trondmy@kernel.org wrote:

> From: Trond Myklebust <trond.myklebust@hammerspace.com>
>
> nfs_inc_stats() is already thread-safe, and there are no other reasons
> to hold the inode lock here.
>
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>

Reviewed-by: Benjamin Coddington <bcodding@redhat.com>

Ben

