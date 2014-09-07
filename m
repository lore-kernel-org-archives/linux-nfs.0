Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:37726 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010AbaIGU7d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Sep 2014 16:59:33 -0400
Received: by mail-vc0-f176.google.com with SMTP id ik5so14202706vcb.7
        for <linux-nfs@vger.kernel.org>; Sun, 07 Sep 2014 13:59:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140907165703.GA21500@lst.de>
References: <1410104201-32517-1-git-send-email-hch@lst.de>
	<1410104201-32517-2-git-send-email-hch@lst.de>
	<CAHQdGtTe_mi_0N6hGApfrx_3TtL7=btWZNc9wd3hrkMdLRVfzQ@mail.gmail.com>
	<20140907165703.GA21500@lst.de>
Date: Sun, 7 Sep 2014 15:59:31 -0500
Message-ID: <CAHQdGtTGdt8THhFRzx7KkwbbxOmBvXLbWozC8zzZeU0L6p+4pw@mail.gmail.com>
Subject: Re: [PATCH 2/2] nfs: update time staps on truncate
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 7, 2014 at 11:57 AM, Christoph Hellwig <hch@lst.de> wrote:
> [patch 1 in the series still seems worthwhile for the client, though]

Agreed, and I plan to apply that.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
