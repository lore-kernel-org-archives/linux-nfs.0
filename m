Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32965 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753158AbaCXNiA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Mar 2014 09:38:00 -0400
Message-ID: <53303534.7080601@RedHat.com>
Date: Mon, 24 Mar 2014 09:37:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils/systemd PATCH 0/6] Assorted fixes for systemd units
References: <20140220065345.7320.49992.stgit@notabene.brown>
In-Reply-To: <20140220065345.7320.49992.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/20/2014 01:55 AM, Neil Brown wrote:
> These are a number of ad-hoc things I.  The nfs-utils_env.sh for SUSE
> is primarily presented as an example.  I'm happy for it to get
> applied, but I'm happy if it isn't applied too.
> 
> Thanks,
> NeilBrown
> 
> 
> ---
> 
> Neil Brown (6):
>       systemd units: remove reference to nfs-server.target from nfs-server.service.
>       systemd units: create nfs-config.service as single location to process config.
Committed to both of test to the systemd branch, with typo fixed.
>       systemd: add nfs-utils_env.sh for SUSE.
Did not commit this one. 

>       systemd: remove @localstatedir@ marking.
>       systemd: nfs-client needs rpc-svcgssd too.
>       systemd: add PIDFile directives where appropriate.
Committed these three to the systemd branch.

I'm planning on move these on the main branch very soon
they will be in the upcoming release.

steved.

> 
> 
>  systemd/README                   |    3 +-
>  systemd/SUSE-nfs-utils_env.sh    |   62 ++++++++++++++++++++++++++++++++++++++
>  systemd/nfs-blkmap.service       |    1 +
>  systemd/nfs-client.target        |    5 ++-
>  systemd/nfs-config.service       |    7 ++++
>  systemd/nfs-idmapd.service       |    5 ++-
>  systemd/nfs-mountd.service       |    5 ++-
>  systemd/nfs-server.service       |    5 ++-
>  systemd/rpc-gssd.service         |    4 ++
>  systemd/rpc-statd-notify.service |    5 ++-
>  systemd/rpc-statd.service        |    6 ++--
>  systemd/rpc-svcgssd.service      |    7 ++--
>  12 files changed, 97 insertions(+), 18 deletions(-)
>  create mode 100644 systemd/SUSE-nfs-utils_env.sh
>  create mode 100644 systemd/nfs-config.service
> 
