Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:43278 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757946AbZCMCjU (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Thu, 12 Mar 2009 22:39:20 -0400
Message-ID: <49B9C84B.2010506@sgi.com>
Date: Fri, 13 Mar 2009 13:43:23 +1100
From: Greg Banks <gnb@sgi.com>
To: Jim Callahan <callahan@temerity.us>
CC: linux-nfs@vger.kernel.org
Subject: Re: Best A->B large file copy performance
References: <49B9780B.2020609@temerity.us>
In-Reply-To: <49B9780B.2020609@temerity.us>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Jim Callahan wrote:
> I'm trying to determine the most optimal way to have a single NFS
> client copy large numbers (100-1000) of fairly large (1-50M) files [...]
I'd like to propose a new rule of thumb:  to be considered "fairly
large", a file should be larger than the capacity of a USB key which
could be comfortably swallowed.

> [...] Since the number of permutations of these three settings are
> large I was hoping that I might get some advise from this list about a
> range of values we should be investigating and any unpleasant
> interactions between these levels of settings we should be aware of to
> narrow our search.  Also, if there are other major factors outside
> those listed I'd appreciate being pointed in the right direction.
Try

http://mirror.linux.org.au/pub/linux.conf.au/2008/slides/130-lca2008-nfs-tuning-secrets-d7.odp

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

