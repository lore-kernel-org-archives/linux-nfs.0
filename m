Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:44782 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757073Ab0LBQ6o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Dec 2010 11:58:44 -0500
Date: Thu, 2 Dec 2010 11:58:42 -0500
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] SQUASHME: blkmapd: fix pretty_sig short sig endianess
 agnosticity
Message-ID: <20101202165842.GA15530@merit.edu>
References: <4CF7A64D.8040802@panasas.com>
 <1291300542-14378-1-git-send-email-bhalevy@panasas.com>
 <20101202162448.GB15055@merit.edu>
 <4CF7C999.4070707@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CF7C999.4070707@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

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

That works for me, yes.
