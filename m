Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34450 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753616AbeFDOx0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 10:53:26 -0400
Received: by mail-it0-f66.google.com with SMTP id y127-v6so10598111itd.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 07:53:26 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id 69-v6sm5035117iod.52.2018.06.04.07.53.24
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 07:53:25 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id w54ErNjN004623
        for <linux-nfs@vger.kernel.org>; Mon, 4 Jun 2018 14:53:23 GMT
Subject: [PATCH v1 0/2] Improve construction of non-UCS
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Mon, 04 Jun 2018 10:53:23 -0400
Message-ID: <20180604144154.11877.19298.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The following series proposes improvements to the default NFSv4.0
client ID strings. The purpose is to decrease the chance that two
distinct clients will choose the same string, and to make the same
client connecting via different transports choose the same string.

The use of the nodename comes from the NFSv4.1 (uniform) client
ID string. It has some shortcomings as well, but it is better
overall than using the client's local address. The use of the
uniquifier is also copied from the uniform client ID string.

The goal is to make the default behavior better. Preventing a
malicious administrator from choosing the same nodename, uniquifier,
and/or client address on purpose is not possible.

---

Chuck Lever (2):
      NFSv4.0: Remove cl_ipaddr from non-UCS client ID
      NFSv4.0: Remove transport protocol name from non-UCS client ID


 fs/nfs/nfs4proc.c |   24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

--
Chuck Lever
