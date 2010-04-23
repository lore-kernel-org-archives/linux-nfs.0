From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] make capabilities support optional
Date: Fri, 23 Apr 2010 12:29:17 -0400
Message-ID: <4BD1CADD.4050200@RedHat.com>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754687Ab0DWRAr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 13:00:47 -0400
In-Reply-To: <1271753213-17374-1-git-send-email-vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/20/2010 04:46 AM, Mike Frysinger wrote:
> The new code using libcap is quite minor, so rather than always reqiure
> libcap support, make it a normal --enable type flag.  Current default
> behavior is retained -- if libcap is found, it is enabled, else it is
> disabled like every nfs-utils version in the past.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>
Committed...

steved.
