From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NFSD: fix use of setsockopt
Date: Thu, 26 Jun 2008 13:14:12 -0400
Message-ID: <20080626171412.GC6961@fieldses.org>
References: <485A6033.3090301@citi.umich.edu> <20080625193757.GF12629@fieldses.org> <4862AE1F.5050902@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
To: Olga Kornievskaia <aglo@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49235 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716AbYFZR4J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jun 2008 13:56:09 -0400
In-Reply-To: <4862AE1F.5050902@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 25, 2008 at 04:44:15PM -0400, Olga Kornievskaia wrote:
> Looking at the kernel code, when setsockopt() is called on a UDP socket  
> to set send/receive buffer for UPD the code will not do anything:  
> udp_setsockopt() and udp_lib_setsockopt() will return -ENOPROTOOPT.  
> However, we bypass the call to setsockopt() and instead set the buffer  
> sizes directly. From what I understand sk_sndbuf/sk_rcvbuf are not used  
> by the UDP code. We are setting the fields that are never used.
>
> Then perhaps we can remove calls to svc_sock_setbufsize() from  
> svc_udp_init() and svc_udp_recvfrom()?

Assuming you're correct about udp not using those fields (haven't
checked myself)--yes, that'd be great.

--b.
