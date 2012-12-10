Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35025 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752443Ab2LJXIO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2012 18:08:14 -0500
Date: Mon, 10 Dec 2012 18:08:10 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jim Rees <rees@umich.edu>
Cc: bjschuma@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFSD: Pass correct buffer size to rpc_ntop
Message-ID: <20121210230810.GE17350@fieldses.org>
References: <1354915049-6892-1-git-send-email-bjschuma@netapp.com>
 <20121207234420.GA11001@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121207234420.GA11001@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 07, 2012 at 06:44:20PM -0500, Jim Rees wrote:
> bjschuma@netapp.com wrote:
> 
>   From: Bryan Schumaker <bjschuma@netapp.com>
>   
>   I honestly have no idea where I got 129 from, but it's a much bigger
>   value than the actual buffer size (INET6_ADDRSTRLEN).
> 
> 128 for the number of bits in an ip6 address, plus one more for the null
> terminator bit?
> 
> (yes, I'm joking, for those of you with no sense of humor)

Hm.

Anyway, applying....

--b.
