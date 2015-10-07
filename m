Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33877 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbJGS5V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Oct 2015 14:57:21 -0400
Received: by obbda8 with SMTP id da8so20833580obb.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2015 11:57:21 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 7 Oct 2015 14:57:21 -0400
Message-ID: <CAHQdGtQTDeYN4ZQn8=zV4WwTQG-FWoLNb4H-kTwJo_nRsy3g6g@mail.gmail.com>
Subject: RCU caching regression in kernel v4.1+
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, lawa@nvidia.com,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Al,

Please could you take a look at the bugzilla entry in
https://bugzilla.kernel.org/show_bug.cgi?id=104911 ?

It describes a NFS caching regression that appears to be caused by
commit 766c4cbfacd8634d7580bac6a1b8456e63de3e84 ("namei:
d_is_negative() should be checked before ->d_seq validation").

Shouldn't that test for 'if (negative) return -ENOENT;' happen after
the call to d_revalidate() in lookup_fast()? If not, we can end up
caching negative dentries forever, AFAICS...

Cheers
  Trond
