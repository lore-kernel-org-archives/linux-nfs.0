Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:35600 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750869AbdAXPoX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 10:44:23 -0500
Received: by mail-qt0-f170.google.com with SMTP id x49so188190081qtc.2
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 07:44:23 -0800 (PST)
Received: from cpe-2606-A000-1125-405B-DECE-A663-7B68-BD3E.dyn6.twc.com (cpe-2606-A000-1125-405B-DECE-A663-7B68-BD3E.dyn6.twc.com. [2606:a000:1125:405b:dece:a663:7b68:bd3e])
        by smtp.gmail.com with ESMTPSA id h40sm16338949qtb.6.2017.01.24.07.44.20
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Jan 2017 07:44:21 -0800 (PST)
Message-ID: <1485272659.3143.18.camel@redhat.com>
Subject: regression in DIO write behavior
From: Jeff Layton <jlayton@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Tue, 24 Jan 2017 10:44:19 -0500
Content-Type: multipart/mixed; boundary="=-Z2elQcR+PtmBErEKXOw6"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Z2elQcR+PtmBErEKXOw6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

I've noticed a probable regression in recent kernels. When you run the
attached program on an older kernel (I used 2.6.32-642.6.2.el6.x86_64),
I see the kernel generate wsize WRITE calls on the wire.

When I run the same program on a more modern kernel (mainline as of
today), it generates a ton of page-sized I/Os instead. I've verified
that iov_iter_get_pages_alloc is returning a wsize array of pages, it
just seems like the request handling code isn't stitching them together
like it should.

Is this an expected change or a regression? I'm guessing the latter, and
that it might have crept in during the pageio rework from a couple of
years ago.

Any idea where the bug might be?
-- 
Jeff Layton <jlayton@redhat.com>
--=-Z2elQcR+PtmBErEKXOw6
Content-Disposition: attachment; filename="diotest2.c"
Content-Type: text/x-csrc; name="diotest2.c"; charset="UTF-8"
Content-Transfer-Encoding: base64

I2RlZmluZSBfR05VX1NPVVJDRQoKI2luY2x1ZGUgPHN5cy90eXBlcy5oPgojaW5jbHVkZSA8c3lz
L3N0YXQuaD4KI2luY2x1ZGUgPGZjbnRsLmg+CiNpbmNsdWRlIDxzdGRpby5oPgojaW5jbHVkZSA8
c3lzL3Vpby5oPgojaW5jbHVkZSA8dW5pc3RkLmg+CiNpbmNsdWRlIDxzdGRsaWIuaD4KCiNkZWZp
bmUJTlVNX1BBR0VTCSgyNTYpCgppbnQgbWFpbihpbnQgYXJnYywgY2hhciAqKmFyZ3YpCnsKCWlu
dCByZXQsIGZkOwoJbG9uZyBwYWdlc2l6ZTsKCXN0cnVjdCBpb3ZlYwlpb3Y7CgoJaWYgKGFyZ2Mg
PCAyKSB7CgkJZnByaW50ZihzdGRlcnIsICJVc2FnZTogJXMgPGZpbGVuYW1lPlxuIiwgYXJndlsw
XSk7CgkJcmV0dXJuIDE7Cgl9CgoJcGFnZXNpemUgPSBzeXNjb25mKF9TQ19QQUdFU0laRSk7Cglp
ZiAocGFnZXNpemUgPCAwKSB7CgkJcGVycm9yKCJzeXNjb25mIik7CgkJcmV0dXJuIDE7Cgl9CgoJ
ZmQgPSBvcGVuKGFyZ3ZbMV0sIE9fQ1JFQVR8T19XUk9OTFl8T19ESVJFQ1QsIDA2NjYpOwoJaWYg
KGZkIDwgMCkgewoJCXBlcnJvcigib3BlbiIpOwoJCXJldHVybiAxOwoJfQoKCXJldCA9IHBvc2l4
X21lbWFsaWduKCZpb3YuaW92X2Jhc2UsIHBhZ2VzaXplLCBwYWdlc2l6ZSAqIE5VTV9QQUdFUyk7
CglpZiAocmV0KSB7CgkJcGVycm9yKCJwb3NpeF9tZW1hbGlnbiIpOwoJCXJldHVybiAxOwoJfQoJ
aW92Lmlvdl9sZW4gPSBwYWdlc2l6ZSAqIE5VTV9QQUdFUzsKCglyZXQgPSB3cml0ZXYoZmQsICZp
b3YsIDEpOwoJaWYgKHJldCA8IDApIHsKCQlwZXJyb3IoIndyaXRldiIpOwoJCXJldHVybiAxOwoJ
fQoKCXJldHVybiAwOwp9Cg==


--=-Z2elQcR+PtmBErEKXOw6--

