Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.7 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9113FC64E7C
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Dec 2020 15:22:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2F2A420B1F
	for <linux-nfs@archiver.kernel.org>; Wed,  2 Dec 2020 15:22:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728380AbgLBPW0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 2 Dec 2020 10:22:26 -0500
Received: from us-smtp-delivery-124.mimecast.com ([216.205.24.124]:23036 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1728364AbgLBPW0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Dec 2020 10:22:26 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1606922460;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding;
        bh=wMzcfrWrNjgQZBHdcBRQgxpfnMgDeV7LUnXg7WPlG7Q=;
        b=bWLM62HZ22itcCH++A/ymN3w95Whjqac4ZAgyBbpfvSbGCxoPZ9iz2ZnzjGMbxFdqUX4wy
        Vh7zVhjQzez1iNaBUjBBVrlI4lffFSw4pvDnBreR+goCNRHOMWHoMuDMJcz+8Adzj9oYaM
        MiHjrGqUvv3i2J8K1/3CZqbrrtXqp20=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-423-yvYUBv-APHeCFBb8uu0DIw-1; Wed, 02 Dec 2020 10:20:58 -0500
X-MC-Unique: yvYUBv-APHeCFBb8uu0DIw-1
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 0CF2E100C601;
        Wed,  2 Dec 2020 15:20:57 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (ovpn-112-97.phx2.redhat.com [10.3.112.97])
        by smtp.corp.redhat.com (Postfix) with ESMTP id ABC8E6086F;
        Wed,  2 Dec 2020 15:20:56 +0000 (UTC)
From:   Steve Dickson <SteveD@RedHat.com>
Subject:  ANNOUNCE: libtirpc-1.3.1 released.
To:     libtirpc <libtirpc-devel@lists.sourceforge.net>
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <e41d93b6-493f-f440-5064-b22128b842cc@RedHat.com>
Date:   Wed, 2 Dec 2020 10:21:26 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.4.0
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hello,

The 1.3.1 version of libtirpc has just been release.

In this release the AUTH_DES function declaration
have been removed from auth_des.h which will 
cause future apps not to build when they try 
to used the unsupported functions 

The API will be remain stable since the unsupported
functions will continue to return an error. 

The tarball:
   http://sourceforge.net/projects/libtirpc/files/libtirpc/1.3.1/libtirpc-1.3.1.tar.bz2

Release notes:
    http://sourceforge.net/projects/libtirpc/files/libtirpc/1.3.1/Release-1.3.1.txt

The git tree is at:
   git://linux-nfs.org/~steved/libtirpc


steved.

