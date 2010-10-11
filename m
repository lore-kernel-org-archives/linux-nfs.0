From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 00/15] Fixes for nfs-utils-1.2.4
Date: Mon, 11 Oct 2010 11:18:34 -0400
Message-ID: <357CCE21-A0D3-4E69-BAAB-32FE10EDFE9D@oracle.com>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011151615.30cbefd3@notabene>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59393 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669Ab0JKPTF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Oct 2010 11:19:05 -0400
In-Reply-To: <20101011151615.30cbefd3@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 11, 2010, at 12:16 AM, Neil Brown wrote:

> On Sun, 10 Oct 2010 20:04:01 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
>> Steve-
>> 
>> Here are fifteen patches which address several mount and mountd bugs
>> and correct other minor problems in nfs-utils-1.2.3.  Now that the
>> bake-a-thon event has passed, folks should have some spare moments to
>> review these.
> 
> Hi,
> here is another you might like to add to the list.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

> 
> gcc complained:
> 
> client.c: In function 'init_netmask6':
> client.c:181:1: warning: no return statement in function returning non-void
> 
> and Suse' build system complained
> 
> I: Program returns random data in a function
> E: nfs-utils no-return-in-nonvoid-function client.c:181
> 
> when I built without --enable-ipv6
> 
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> 
> diff --git a/support/export/client.c b/support/export/client.c
> index dbfc2b1..ba2db8f 100644
> --- a/support/export/client.c
> +++ b/support/export/client.c
> @@ -178,6 +178,7 @@ out_badprefix:
> static int
> init_netmask6(nfs_client *UNUSED(clp), const char *UNUSED(slash))
> {
> +	return 0;
> }
> #endif	/* IPV6_SUPPORTED */
> 

-- 
chuck[dot]lever[at]oracle[dot]com




