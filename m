Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:40484 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757143Ab0LBQaU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 11:30:20 -0500
Message-ID: <4CF7C999.4070707@panasas.com>
Date: Thu, 02 Dec 2010 18:30:17 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] SQUASHME: blkmapd: fix pretty_sig short sig endianess
 agnosticity
References: <4CF7A64D.8040802@panasas.com> <1291300542-14378-1-git-send-email-bhalevy@panasas.com> <20101202162448.GB15055@merit.edu>
In-Reply-To: <20101202162448.GB15055@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-12-02 18:24, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>   ---
>   
>   How about this?
>   
>   Benny
>   
>    utils/blkmapd/device-process.c |   14 ++++++++++----
>    1 files changed, 10 insertions(+), 4 deletions(-)
>   
>   diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
>   index 0c5060b..0584bf9 100644
>   --- a/utils/blkmapd/device-process.c
>   +++ b/utils/blkmapd/device-process.c
>   @@ -52,11 +52,17 @@
>    static char *pretty_sig(char *sig, uint32_t siglen)
>    {
>    	static char rs[100];
>   -	unsigned long i = 0;
>   +	uint64_t sigval;
>    
>   -	if (siglen <= sizeof i) {
>   -		memcpy(&i, sig, siglen);
>   -		sprintf(rs, "0x%0lx", i);
>   +	if (siglen <= sizeof(sigval)) {
>   +		int i;
>   +
>   +		sigval = 0;
>   +		for (i = 0; i < siglen; i++) {
>   +			sigval <<= 8;
>   +			sigval += ((unsigned char *)sig)[i];
>   +		}
>   +		sprintf(rs, "0x%0llx", sigval);
>    	} else {
>    		if (siglen > sizeof rs - 1)
>    			siglen = sizeof rs - 1;
> 
> I would prefer to print it as little-endian, since that's how it's supplied
> by the EMC server.

Like this?

diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
index ea8b8ec..0d8705f 100644
--- a/utils/blkmapd/device-process.c
+++ b/utils/blkmapd/device-process.c
@@ -58,10 +58,8 @@ static char *pretty_sig(char *sig, uint32_t siglen)
 		int i;
 
 		sigval = 0;
-		for (i = 0; i < siglen; i++) {
-			sigval <<= 8;
-			sigval += ((unsigned char *)sig)[i];
-		}
+		for (i = 0; i < siglen; i++)
+			sigval |= ((unsigned char *)sig)[i] << (i * 8);
 		sprintf(rs, "0x%0llx", sigval);
 	} else {
 		if (siglen > sizeof rs - 4) {
