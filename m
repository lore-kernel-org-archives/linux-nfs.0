Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f178.google.com ([209.85.220.178]:35691 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbBWWeD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Feb 2015 17:34:03 -0500
Received: by mail-vc0-f178.google.com with SMTP id hq11so8586387vcb.9
        for <linux-nfs@vger.kernel.org>; Mon, 23 Feb 2015 14:34:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
Date: Mon, 23 Feb 2015 17:34:02 -0500
Message-ID: <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chris Perl <cperl@janestreet.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Chris Perl <chris.perl@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 23, 2015 at 3:56 PM, Chris Perl <cperl@janestreet.com> wrote:
> I'm currently experiencing an issue where reading from a file that is
> known to only contain ascii characters can result in the process
> reading that file seeing NULL bytes (0x0) in the file that never
> existed.  This happens for NFSv3 clients when the file is being
> updated concurrently either by another NFSv3 client or directly on the
> NFS server.

That's expected behaviour, yes. NFS close-to-open cache consistency
semantics do not allow for concurrent access while the file is being
updated.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
