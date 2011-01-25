Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gossamer.nmsrv.com ([208.70.244.21]:53980 "EHLO
	gossamer.nmsrv.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827Ab1AYXZA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 18:25:00 -0500
Message-ID: <4D3F5BC5.7070709@gt.net>
Date: Tue, 25 Jan 2011 15:24:53 -0800
From: Nathan March <nathan@gt.net>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Stale file not being refreshed automatically?
References: <4D3F4A8A.7040003@gt.net> <1295994532.6867.12.camel@heimdal.trondhjem.org>
In-Reply-To: <1295994532.6867.12.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 1/25/2011 2:28 PM, Trond Myklebust wrote:
> On Tue, 2011-01-25 at 14:
> Does '-e' in perl only do a lookup, or does it result in a 'stat()'
> call? If the latter, then your test is flawed: a stat() is a lookup+a
> getattr, and the latter can definitely return ESTALE when you are
> constantly replacing the file.
>
> Cheers
>    Trond

Hi Trond,

Has any behavior here changed between 2.6.19 and 2.6.32 that you know of?

Testing that perl one liner out with a variety of nfs setups we run:

2.6.11 client vs 2.6.32 server - no error
2.6.11 client vs netapp - no error
2.6.19 client vs 2.6.19 server - no error
2.6.19 client vs netapp - no error
2.6.32 client vs 2.6.32 server - stale file handles
2.6.32 client vs netapp - stale file handles

So it seems to be a client specific change sometime between 2.6.19 and 
2.6.32....

- Nathan
