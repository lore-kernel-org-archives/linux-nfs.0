From: Nathan March <nathan-NuwpVtnOm/s@public.gmane.org>
Subject: Re: Stale file not being refreshed automatically?
Date: Tue, 25 Jan 2011 15:29:20 -0800
Message-ID: <4D3F5CD0.9010204@gt.net>
References: <4D3F4A8A.7040003@gt.net> <1295994532.6867.12.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gossamer.nmsrv.com ([208.70.244.21]:38291 "EHLO
	gossamer.nmsrv.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754020Ab1AYX32 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jan 2011 18:29:28 -0500
In-Reply-To: <1295994532.6867.12.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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
