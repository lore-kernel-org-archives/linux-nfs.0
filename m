Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:34834 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558AbcCXTA4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2016 15:00:56 -0400
Received: by mail-ob0-f176.google.com with SMTP id fp4so45002406obb.2
        for <linux-nfs@vger.kernel.org>; Thu, 24 Mar 2016 12:00:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160324133551.GA21950@fieldses.org>
References: <20160324133551.GA21950@fieldses.org>
Date: Thu, 24 Mar 2016 15:00:55 -0400
Message-ID: <CAHQdGtQWNaTVVBA7VxRHh2jmxCVO_7pMHXt6JEQsLr0K9TThtg@mail.gmail.com>
Subject: Re: [GIT PULL] nfsd changes for 4.6
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Jeff Layton <jlayton@primarydata.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 24, 2016 at 9:35 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> Please pull nfsd changes for 4.6 from
>
>   git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.6
>
> ----------------------------------------------------------------
> Various bugfixes, a RDMA update from Chuck Lever, and support for a new
> pnfs layout type from Christoph Hellwig.  The new layout type is a
> variant of the block layout which uses SCSI features to offer improved
> fencing and device identification.
>
> (Also: note this pull request also includes the client side of SCSI
> layout, with Trond's permission.)

Umm.... Did you forget to include those patches, Bruce?
