Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54159 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758259Ab0HDPJC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:09:02 -0400
Subject: Re: [PATCH 0/3] Some IPv6 enhancements for nfs-utils
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100804064553.16641.92857.stgit@localhost.localdomain>
Date: Wed, 4 Aug 2010 11:08:07 -0400
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <FDC92B80-A12A-478D-95D1-2E75194BBFAA@oracle.com>
References: <20100804064553.16641.92857.stgit@localhost.localdomain>
To: Neil Brown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Neil-

On Aug 4, 2010, at 2:49 AM, Neil Brown wrote:

> Hi Chuck et al,
> I've been playing with IPv6 server support and offer these patches
> which get us a little bit closer.
> I realise that you may already have similar patches queued in which
> case feel free to ignore these.

The full series of patches giving mountd IPv6 support is in my git repo on linux-nfs.org.  See:

  http://git.linux-nfs.org/?p=cel/nfs-utils.git;a=summary

This is what we have queued up.  We're taking a resting stop for the next nfs-utils release since the pre-requisite patches touched so many parts of mountd, and we'd like to give them some soak time.

If SuSE requires NFS server-side IPv6 support, would it be possible for you to try out my series?  It looks like you touched all the important bases in your patch set.

> With these plus a couple of #defines of IPV6_SUPPORTED I can export
> with NFSv4 over IPv6 quite successfully.
> 
> NeilBrown
> 
> ---
> 
> Neil Brown (3):
>      Make buffers large enough for IPv6 addresses
>      Give hostname.c more support for IPv6
>      Allow check_fqdn to compare IPv6 addresses
> 
> 
> support/export/client.c   |   23 +----------------------
> support/export/hostname.c |   28 +++++++++++++++++++---------
> utils/mountd/cache.c      |    6 +++---
> utils/mountd/rmtab.c      |    2 +-
> 4 files changed, 24 insertions(+), 35 deletions(-)
> 
> -- 
> Signature
> 

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



