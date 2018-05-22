Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:50360 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752075AbeEVPxp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2018 11:53:45 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.3 \(3445.6.18\))
Subject: EVM HMAC and FS UUID
Message-Id: <04B6BFF9-AC1E-4E46-810B-7DDE5ED63345@oracle.com>
Date: Tue, 22 May 2018 08:53:34 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: trond.myklebust@hammerspace.com,
        Bruce Fields <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I'm continuing to look at NFS support for the Linux Integrity
Measurement Architecture.

When computing an HMAC hash of file attributes, sometimes the
FS UUID is included. For a client to verify that hash, the
server will have to expose that UUID somehow.

Is there currently an NFSv4 attribute that carries the FS UUID?


--
Chuck Lever



