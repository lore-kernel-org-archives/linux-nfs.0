Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:33970 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932637AbbJIRor (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2015 13:44:47 -0400
Received: by ykdg206 with SMTP id g206so85041418ykd.1
        for <linux-nfs@vger.kernel.org>; Fri, 09 Oct 2015 10:44:47 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Leandro Awa <lawa@nvidia.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        linux-kernel@vger.kernel.org
Subject: [PATCH] namei: results of d_is_negative() should be checked after dentry revalidation
Date: Fri,  9 Oct 2015 13:44:34 -0400
Message-Id: <1444412674-3077-1-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <9459055931ab4f269b96bad953738778@HQMAIL102.nvidia.com>
References: <9459055931ab4f269b96bad953738778@HQMAIL102.nvidia.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Leandro Awa writes:
After switching to version 4.1.6, our parallelized and distributed workflows now  fail consistently with errors of the form:

T34: ./regex.c:39:22: error: config.h: No such file or directory
