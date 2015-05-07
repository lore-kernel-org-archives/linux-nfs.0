Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57016 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbbEGUMr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2015 16:12:47 -0400
Message-ID: <554BC730.3000004@RedHat.com>
Date: Thu, 07 May 2015 16:12:32 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Thorsten Kukuk <kukuk@suse.de>
CC: Mike Frysinger <vapier@gentoo.org>, libtirpc-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org
Subject: Re: [Libtirpc-devel] [PATCH libtirpc] fix build w/gssapi disabled
References: <1430983149-22199-1-git-send-email-vapier@gentoo.org> <20150507115248.GA20243@suse.de> <554B86E2.8090908@RedHat.com> <20150507163326.GA6156@suse.de> <554B98E9.4040601@RedHat.com> <20150507181206.GA7810@suse.de> <554BC53C.5080807@RedHat.com>
In-Reply-To: <554BC53C.5080807@RedHat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/07/2015 04:04 PM, Steve Dickson wrote:
>> > This needs to be "#ifdef HAVE_GSSAPI", HAVE_RPCSEC_GSS
>> > will never be defined if the header is used outside of
>> > libtirpc sources
> When I do that I get the following errors when the gssapi is
> enabled:
> 
> svc_auth_gss.c: In function 'rpc_gss_getcred':
> svc_auth_gss.c:920:7: error: 'SVCAUTH' has no member named 'raw_cred'
>    auth->raw_cred = gd->rcred;
>        ^
Pilot error on my part... #ifdef HAVE_GSSAPI does work.

Sorry for the noise.

steved.
