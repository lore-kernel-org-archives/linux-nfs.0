Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252Ab3GAQXZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 12:23:25 -0400
Message-ID: <51D1ACFA.2010203@RedHat.com>
Date: Mon, 01 Jul 2013 12:23:22 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/3] gssd: add -N option to use root credentials as machine
 credentials.
References: <20130603005219.20080.1927.stgit@notabene.brown> <20130603010022.20080.88360.stgit@notabene.brown>
In-Reply-To: <20130603010022.20080.88360.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil,

On 02/06/13 21:00, Neil Brown wrote:
> Since linux-3.7, the kernel asks explicitly for machine credentials
> rather than root credentials to authenticate state management requests.
> 
> This causes a regression for people who do not have machine
> credentials configured and were using "gssd -n" to instruct gssd to
> disable the default mapping of using machine credentials to authorise
> accesses by 'root'.
> 
> This patch adds '-N' flag which instruct gssd explicitly to use 'root'
> credentials whenever 'machine' credentials are requested.  Thus
>   gssd -n -N
> provides the same service that
>   gssd -n
> used to.
> 
> In summary:
> 
> Credentials used for different request types and different gssd flags:
> 
>    Request type: |     "gssd"      "gssd -n"   "gssd -N"    "gssd -nN"
>                  |
>      machine     |     machine      machine     root         root
>                  |
>      root        |     machine      root        machine      root
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
So is this no longer needed do the kernel change you and Chuck came up with?

steved.
