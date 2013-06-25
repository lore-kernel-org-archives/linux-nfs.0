Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f172.google.com ([209.85.223.172]:46428 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752453Ab3FYVE7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 17:04:59 -0400
Received: by mail-ie0-f172.google.com with SMTP id 16so29397299iea.31
        for <linux-nfs@vger.kernel.org>; Tue, 25 Jun 2013 14:04:58 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 25 Jun 2013 14:04:58 -0700
Message-ID: <CABgxfbGOxbLTGNuVFuts367vZru8VLXCYWx6d3m_xeyVgUZwuA@mail.gmail.com>
Subject: NFS4 Lock Lease
From: Wendy Cheng <s.wendy.cheng@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have not looked at how NFS4 handles its lock lease yet. Could
someone pass few pointers ? The specific question I have is the
perpetuity issue - that is, how does (or will) NFS4 lock lease prevent
a lock owner from taking the lock for an extended duration (or even
indefinitely) ?

Thanks,
Wendy
