Return-Path: linux-nfs-owner@vger.kernel.org
Received: from peace.netnation.com ([204.174.223.2]:57690 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756213Ab2CBAZM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 19:25:12 -0500
Date: Thu, 1 Mar 2012 16:25:11 -0800
From: Simon Kirby <sim@hostway.ca>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [3.1-rc4] NFSv3 client hang
Message-ID: <20120302002511.GA4495@hostway.ca>
References: <20110909194509.GB6195@hostway.ca> <1315610322.17611.112.camel@lade.trondhjem.org> <20111020190334.GA22772@hostway.ca> <20120301225524.GB27595@hostway.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120301225524.GB27595@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 01, 2012 at 02:55:24PM -0800, Simon Kirby wrote:

> Here's another one, from 3.2.2. I guess it's still happening. :/

In cleaning this one up, "umount -t nfs -a -l" left the socket there
still in CLOSE_WAIT. There were a few stuck "df" processes from our
monitoring script:

31370 D<   df -mPt nfs                 rpc_wait_bit_killable
31822 D<   df -mPt nfs                 rpc_wait_bit_killable
31847 D<   df -mPt nfs                 rpc_wait_bit_killable

...killing those made the socket actually close and change to TIME_WAIT,
allowing me to remount everything, and it all works again.

Simon-
