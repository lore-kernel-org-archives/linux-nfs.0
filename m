Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42854 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134Ab0GZPVn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jul 2010 11:21:43 -0400
Received: by pwi5 with SMTP id 5so95594pwi.19
        for <linux-nfs@vger.kernel.org>; Mon, 26 Jul 2010 08:21:42 -0700 (PDT)
Date: Mon, 26 Jul 2010 11:21:40 -0400
Message-ID: <AANLkTinSHDKPO5frmr4sik6ZnIZyOpfsDvXc20W74Df1@mail.gmail.com>
Subject: dentry cache memory usage
From: Casey Bodley <cbodley@umich.edu>
To: linux-nfs@vger.kernel.org
Cc: Olga Kornievskaia <aglo@citi.umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'm a developer at CITI working on the windows pnfs client.  We've
been looking into some optimizations for our name and attribute
caches, mainly involving the use of pools to avoid allocating memory
for each new entry.

We're looking for a sensible initial/maximum pool size.  Once the
maximum pool size is reached, we'll start scavenging the least
recently used entries.  Does the linux client impose any limits on the
size of the dentry cache?

I'm also curious what time limits you're using before expiring cached
attributes and lookups.

I suppose I'm just asking for magic numbers here, in the hope that
smart people have tested and benchmarked this stuff in the linux
client.

Thanks,
Casey
