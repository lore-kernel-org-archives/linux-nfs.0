Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:62723 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754343AbaAITG5 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 14:06:57 -0500
Received: by mail-ie0-f176.google.com with SMTP id at1so4054137iec.35
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 11:06:57 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH RFC] nfs: remove nfs_show_devname
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1389293995-634-1-git-send-email-jlayton@redhat.com>
Date: Thu, 9 Jan 2014 14:06:54 -0500
Cc: "Yin.JianHong" <jiyin@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6FE57B0D-2373-4B40-BA14-E6F2BF3C44E3@primarydata.com>
References: <1389293995-634-1-git-send-email-jlayton@redhat.com>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 9, 2014, at 13:59, Jeff Layton <jlayton@redhat.com> wrote:

> The nfs code will currently construct a devname to show in places like
> /proc/mounts by turning a dentry into a path. Unfortunately, that's
> somewhat problematic if the user ended up mounting through a symlink on
> the server. The devname that then shows up in /proc/mounts now doesn't
> match the one that was originally passed into the mount request.

This is 100% according to design. Why is it suddenly a problem?

By displaying the original pathname, you also end up bypassing referral resolution, etc. This is exactly why the .show_devname operation was introduced in the first place.

--
Trond Myklebust
Linux NFS client maintainer

