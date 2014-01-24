Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:34981 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbaAXFij convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 00:38:39 -0500
Received: by mail-ie0-f178.google.com with SMTP id x13so2352494ief.37
        for <linux-nfs@vger.kernel.org>; Thu, 23 Jan 2014 21:38:38 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] nfs: handle servers that support either ALLOW or DENY ACE types.
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1390535453-15585-1-git-send-email-malahal@us.ibm.com>
Date: Thu, 23 Jan 2014 22:31:18 -0700
Cc: linuxnfs <linux-nfs@vger.kernel.org>
Message-Id: <979899AD-3AD6-4D89-B53F-1E30D4AB078B@primarydata.com>
References: <1390535453-15585-1-git-send-email-malahal@us.ibm.com>
To: Malahal Naineni <malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 23, 2014, at 20:50, Malahal Naineni <malahal@us.ibm.com> wrote:

> Currently we support ACLs if the NFS server file system supports
> ALLOW and DENY ACE types. This patch makes the Linux client work with
> ACLs if the server supports either ALLOW or DENY ACE types.

According to RFC5661, the behaviour if you don’t have ALLOW aces is to deny all access. How does it make sense to accept that?

--
Trond Myklebust
Linux NFS client maintainer

