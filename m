Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60714 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756232AbaISP5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Sep 2014 11:57:34 -0400
Date: Fri, 19 Sep 2014 11:57:33 -0400
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH 0/2] Use the gssproxy damon for GSSAPI credentials
Message-ID: <20140919155733.GA16658@fieldses.org>
References: <1411131103-17254-1-git-send-email-steved@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1411131103-17254-1-git-send-email-steved@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 19, 2014 at 08:51:41AM -0400, Steve Dickson wrote:
> The gssproxy(8) daemon is now how the managing of GSSAPI 
> credentials should be done. 
> 
> These to patches has the nfs-server systemd script start 
> gssproxy instead of rpc.svcgssd and removes the building 
> and installation of rpc.svcgssd.
> 
> For now I'm leaving the source files... Just in case... ;-)

If nothing else, we'd like to keep support for older kernels for a
while.

--b.

> 
> Steve Dickson (2):
>   nfs-server: Replace rpc.svcgssd with gssproxy
>   svcgssd: Remove rules from the Makefile.am
> 
>  systemd/nfs-server.service  |  4 ++--
>  systemd/rpc-svcgssd.service | 19 -------------------
>  utils/gssd/Makefile.am      | 25 ++-----------------------
>  3 files changed, 4 insertions(+), 44 deletions(-)
>  delete mode 100644 systemd/rpc-svcgssd.service
> 
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
