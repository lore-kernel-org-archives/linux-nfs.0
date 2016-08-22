Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57050 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754766AbcHVMyu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Aug 2016 08:54:50 -0400
Subject: Re: [PATCH 0/2] nfs-utils patches relating to server startup
To: NeilBrown <neilb@suse.com>
References: <147157095612.26568.14161646901346011334.stgit@noble>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <3a681593-891e-cb0c-cd0b-76e2358f72cd@RedHat.com>
Date: Mon, 22 Aug 2016 08:54:48 -0400
MIME-Version: 1.0
In-Reply-To: <147157095612.26568.14161646901346011334.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/18/2016 09:45 PM, NeilBrown wrote:
> Two patches for recently discussed functionality.
> Both revert earlier patches and provide a more complete
> solution.
> 
> The first adds a new program.  I've placed this in "systemd/" rather
> than "utils/something" because that seemed to make sense.  Is it
> inelegant putting code in a directory with unit files?
> 
> I don't do a lot of automake coding so if someone were to make sure I
> didn't do anything non-standard in the Makefile.am, that would be
> appreciated.
All three patches committed under the nfs-utils-1-3-5-rc1 tag... 

steved

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
> 
