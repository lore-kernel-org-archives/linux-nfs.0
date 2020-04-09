Return-Path: <SRS0=n3J7=5Z=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CABC8C2BA19
	for <linux-nfs@archiver.kernel.org>; Thu,  9 Apr 2020 18:06:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9207320757
	for <linux-nfs@archiver.kernel.org>; Thu,  9 Apr 2020 18:06:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="bXQ/js6C"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725987AbgDISGl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 9 Apr 2020 14:06:41 -0400
Received: from us-smtp-delivery-1.mimecast.com ([205.139.110.120]:43988 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1725970AbgDISGl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2020 14:06:41 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1586455601;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=twQua96iYwnYiRi/2CpStR41wiP89KFLTm/DLCyvqtA=;
        b=bXQ/js6Cvr7uQ74C7mZorVT72dqz5Xz/vuNVB+v09MLaB+zMvxgLX6b0mxNulJZhHO//jo
        dFEC3MoKOGp4wIHQe/gY5MZ6mmkZ3KSnksHGGmgb0jhyoNQREk3UDr+mln2RMpTrd3uMtf
        hpVCv4fTHCRo5iYiiE3u8ruBANWwN4w=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-342-aMc4gLPpN_aBUjCGTg5tZA-1; Thu, 09 Apr 2020 14:06:38 -0400
X-MC-Unique: aMc4gLPpN_aBUjCGTg5tZA-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 039D61005509;
        Thu,  9 Apr 2020 18:06:38 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-113-92.phx2.redhat.com [10.3.113.92])
        by smtp.corp.redhat.com (Postfix) with ESMTP id A76EB99E01;
        Thu,  9 Apr 2020 18:06:37 +0000 (UTC)
From:   Steve Dickson <SteveD@RedHat.com>
Subject: ANNOUNCE: libtirpc-1.2.6 released.
To:     libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <12a429eb-d29f-4e7c-d36a-128b2746df28@RedHat.com>
Date:   Thu, 9 Apr 2020 14:06:36 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.5.0
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

The 1.2.6 version of libtirpc has just been release.

A fairly minor release... Mostly fixing porting issues.

The tarball:
   http://sourceforge.net/projects/libtirpc/files/libtirpc/1.2.6/libtirpc-1.2.6.tar.bz2

Release notes:
    http://sourceforge.net/projects/libtirpc/files/libtirpc/1.2.6/Release-1.2.6.txt

The git tree is at:
   git://linux-nfs.org/~steved/libtirpc


steved.

