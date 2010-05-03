Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:57311 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011Ab0ECQxP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 12:53:15 -0400
Received: by pxi5 with SMTP id 5so300175pxi.19
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 09:53:15 -0700 (PDT)
Date: Mon, 3 May 2010 12:53:15 -0400
Message-ID: <l2wdc64e7231005030953xb72ad73az3f883167a1a637c8@mail.gmail.com>
Subject: Proxy
From: maillists0@gmail.com
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

With NFS4's support for referrals and Kerberos, it seems like the
original reasons to prevent re-exporting of an NFS share might no
longer exist. With fs-proxy making its way into the mainline kernel
and things like cachefilesd, there are also very good reasons to allow
it. A proxy server with a persistent cache could give the ability to
robustly use shares across a WAN or do failover pairs with no need for
more complex replication. Speaking as an end-user, this would be very
desirable.

I see that others have implemented proxies with user-space NFS, which
seems reasonable but not optimal. What is the obstacle to allowing
re-exports with the standard nfs implentation? Is it possible at the
moment to patch a kernel to make this work? Anyone have experience
with it? Any input is appreciated.
