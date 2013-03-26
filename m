Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934567Ab3CZPHC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 26 Mar 2013 11:07:02 -0400
Message-ID: <5151B994.1070704@RedHat.com>
Date: Tue, 26 Mar 2013 11:07:00 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Mike Frysinger <vapier@gentoo.org>
CC: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH [rpcbind]] rename configure.in to configure.ac
References: <1364162967-9612-1-git-send-email-vapier@gentoo.org>
In-Reply-To: <1364162967-9612-1-git-send-email-vapier@gentoo.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 24/03/13 18:09, Mike Frysinger wrote:
> Newer autotools wants this to end in .ac.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  configure.in => configure.ac | 0
>  1 file changed, 0 insertions(+), 0 deletions(-)
>  rename configure.in => configure.ac (100%)
> 
> diff --git a/configure.in b/configure.ac
> similarity index 100%
> rename from configure.in
> rename to configure.ac
> 
Committed... 

steved.
