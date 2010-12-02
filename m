Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:45370 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757711Ab0LBQYu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 11:24:50 -0500
Date: Thu, 2 Dec 2010 11:24:48 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] SQUASHME: blkmapd: fix pretty_sig short sig endianess
 agnosticity
Message-ID: <20101202162448.GB15055@merit.edu>
References: <4CF7A64D.8040802@panasas.com>
 <1291300542-14378-1-git-send-email-bhalevy@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291300542-14378-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  Signed-off-by: Benny Halevy <bhalevy@panasas.com>
  ---
  
  How about this?
  
  Benny
  
   utils/blkmapd/device-process.c |   14 ++++++++++----
   1 files changed, 10 insertions(+), 4 deletions(-)
  
  diff --git a/utils/blkmapd/device-process.c b/utils/blkmapd/device-process.c
  index 0c5060b..0584bf9 100644
  --- a/utils/blkmapd/device-process.c
  +++ b/utils/blkmapd/device-process.c
  @@ -52,11 +52,17 @@
   static char *pretty_sig(char *sig, uint32_t siglen)
   {
   	static char rs[100];
  -	unsigned long i = 0;
  +	uint64_t sigval;
   
  -	if (siglen <= sizeof i) {
  -		memcpy(&i, sig, siglen);
  -		sprintf(rs, "0x%0lx", i);
  +	if (siglen <= sizeof(sigval)) {
  +		int i;
  +
  +		sigval = 0;
  +		for (i = 0; i < siglen; i++) {
  +			sigval <<= 8;
  +			sigval += ((unsigned char *)sig)[i];
  +		}
  +		sprintf(rs, "0x%0llx", sigval);
   	} else {
   		if (siglen > sizeof rs - 1)
   			siglen = sizeof rs - 1;

I would prefer to print it as little-endian, since that's how it's supplied
by the EMC server.
