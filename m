Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55464 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752680AbdADQ4B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 4 Jan 2017 11:56:01 -0500
Subject: Re: [PATCH 0/4] Assorted nfs-utils patches.
To: NeilBrown <neilb@suse.com>
References: <148227940052.31345.1974080582264239934.stgit@noble>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <d8854243-05f3-0ac3-9cc1-3f13aedbda66@RedHat.com>
Date: Wed, 4 Jan 2017 11:56:00 -0500
MIME-Version: 1.0
In-Reply-To: <148227940052.31345.1974080582264239934.stgit@noble>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/20/2016 07:19 PM, NeilBrown wrote:
> First two relate to /etc/nfs.conf and nfsd.
> Second to help make sure that nfs things don't cause
> problem when they are started early because various
> other services are available (most of that is already
> fixed, these are just dribs and drabs).
> 
> At some stage I want to convert everything to use the same logging
> infrastructure, but that doesn't need to happen before the pending
> release.
> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> NeilBrown (4):
>       nfsd: fix setting of minor version from config file.
>       nfsd: Do not permit manipulation of NFSv4.0, e.g. "-N 4.0"
>       nfs-server-generator: avoid using syslog
>       mountd: delay reading etab until first request arrives.
> 
> 
>  systemd/nfs-server-generator.c |    3 +++
>  utils/mountd/mountd.c          |    2 --
>  utils/nfsd/nfsd.c              |   20 ++++++++++++++++----
>  utils/nfsd/nfsd.man            |   10 +++++-----
>  4 files changed, 24 insertions(+), 11 deletions(-)
All four committed! Thank you!

steved.

> 
> --
> Signature
> 
