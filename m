Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33136 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755317AbcHSVCQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 17:02:16 -0400
Date: Fri, 19 Aug 2016 17:01:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
Subject: Re: [PATCH 0/2] nfs-utils patches relating to server startup
Message-ID: <20160819210152.GP32329@fieldses.org>
References: <147157095612.26568.14161646901346011334.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <147157095612.26568.14161646901346011334.stgit@noble>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 19, 2016 at 11:45:56AM +1000, NeilBrown wrote:
> Two patches for recently discussed functionality.
> Both revert earlier patches and provide a more complete
> solution.
> 
> The first adds a new program.  I've placed this in "systemd/" rather
> than "utils/something" because that seemed to make sense.  Is it
> inelegant putting code in a directory with unit files?

Seems to me like a logical enough spot in this case.--b.

> 
> I don't do a lot of automake coding so if someone were to make sure I
> didn't do anything non-standard in the Makefile.am, that would be
> appreciated.
> 
> Thanks,
> NeilBrown
> 
> ---
> 
> NeilBrown (2):
>       systemd: improve ordering between nfs-server and various mounts
>       mount: RPC_PROGNOTREGISTERED should not be a permanent error
> 
> 
>  systemd/Makefile.am            |    8 ++
>  systemd/nfs-server-generator.c |  144 ++++++++++++++++++++++++++++++++++++++++
>  systemd/nfs-server.service     |    3 -
>  utils/mount/stropts.c          |    7 +-
>  4 files changed, 155 insertions(+), 7 deletions(-)
>  create mode 100644 systemd/nfs-server-generator.c
> 
> --
> Signature
