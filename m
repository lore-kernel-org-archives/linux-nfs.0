Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34190 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755537AbbDXOsA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2015 10:48:00 -0400
MIME-Version: 1.0
In-Reply-To: <20150423151205.GB22158@fieldses.org>
References: <20150423151205.GB22158@fieldses.org>
Date: Fri, 24 Apr 2015 07:47:59 -0700
Message-ID: <CA+55aFy3DxbUn8LRqre2BGTR-tXe=ijOwhHpoZ9Yzdf=KrNnkg@mail.gmail.com>
Subject: Re: [GIT] nfsd changes for 4.0
From: Linus Torvalds <torvalds@linux-foundation.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 23, 2015 at 8:12 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Please pull nfsd changes for 4.0 from:
>
>   git://linux-nfs.org/~bfields/linux.git for-4.0

You meant "for-4.1".

Please script this better so that the pull target itself is also part
of the script - clearly you used the right name at some point since
the shortlog and diffstat is about the right for-4.1 branch...

                        Linus
