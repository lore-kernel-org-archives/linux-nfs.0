Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36235 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754992AbbHKKsW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Aug 2015 06:48:22 -0400
Message-ID: <55C9D2F2.1020300@RedHat.com>
Date: Tue, 11 Aug 2015 06:48:18 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs-utils regression on IPv6-less kernels
References: <20150810131358.GA19466@infradead.org>
In-Reply-To: <20150810131358.GA19466@infradead.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey,

On 08/10/2015 09:13 AM, Christoph Hellwig wrote:
> Hi Steve,
> 
> since commit "ipv6: Enable IPv6 support by default." rpc.mountd
> fails to start on a kernel without IPv6 support.  Seems like it
> doesn't have a proper fallback if an address family isn't implemented.
> 
hmm... What do you mean "fails to start"...  are there any error messages?
If nfs-utils is compiled with the --disable_ipv6 flag, does
the same problem happen?

Note, I'm going on holiday for the next couple weeks so my
response time might be a bit spotty... 

steved.

