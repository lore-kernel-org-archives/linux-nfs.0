Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35373 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754230Ab2DFV4i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Apr 2012 17:56:38 -0400
Received: by vcqp1 with SMTP id p1so929384vcq.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Apr 2012 14:56:38 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
Date: Fri, 6 Apr 2012 23:56:37 +0200
Message-ID: <CAGue13oi+486dGpgsUpn0EkiNmf8pLM60XzjT7q+r3gkzYAL0g@mail.gmail.com>
Subject: corrupted rpc message on GSS_DESTROY
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

We are still see issued described in:

http://www.spinics.net/lists/linux-nfs/msg22142.html

Now even the see partial context.
By looking at kernel's GSS implementation I see following:

The auth_gss.c:gss_marshal() in some cases may return NULL.
The NULL value is passed to xdr_adjust_iovec() which
calculates message length as:

 return iov->iov_len = ((u8 *) p - (u8 *) iov->iov_base);

where p is NULL in such case.  I don't think it's an expected
behavior.

Regards,
   Tigran
