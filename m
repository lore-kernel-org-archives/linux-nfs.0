Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:48908 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbaKCUnR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2014 15:43:17 -0500
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [PATCH 0/2] nfsidmap not setting key timeouts
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <cover.1415036893.git.bcodding@redhat.com>
Date: Mon, 3 Nov 2014 15:43:12 -0500
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <E12E1FC2-1497-4B2A-A171-D972885855E0@oracle.com>
References: <cover.1415036893.git.bcodding@redhat.com>
To: Benjamin Coddington <bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 3, 2014, at 12:49 PM, Benjamin Coddington <bcodding@redhat.com> wrote:

> These should fix up nfsidmap being unable to set key timeouts.
> 
> Benjamin Coddington (2):
>  nfsidmap: set the correct DEFAULT_KEYRING string
>  nfsidmap: Correct a failure to set key timeout values
> 
> utils/nfsidmap/nfsidmap.c |    5 ++++-
> 1 files changed, 4 insertions(+), 1 deletions(-)

This fixed the timeout problem for me with a 3.18-rc3 kernel.

However, I still need to apply the “no state check” fix I posted
last Thursday, or the keys simply expire after 10 minutes and the
kernel never renews them.

http://marc.info/?l=linux-nfs&m=141469121406791&w=2

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



