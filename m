From: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Subject: Re: Text based mount options ignoring the preferred rwsize?
Date: Thu, 10 Sep 2009 10:08:37 +0100
Message-ID: <4AA8C215.2030002@moving-picture.com>
References: <4AA68AA4.7090606@moving-picture.com>	 <188B198A-A113-4CA7-940D-EFBD026CBDD2@oracle.com>	 <4AA8225A.9060107@moving-picture.com> <1252536970.8722.110.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:47088 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754575AbZIJJIj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 05:08:39 -0400
In-Reply-To: <1252536970.8722.110.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2009-09-09 at 22:47 +0100, James Pearson wrote:
> 
>>The default behaviour with binary mount options when no [rw]size is to 
>>select these preferred values - which to me, makes sense - as by not 
>>giving a [rw]size, you are leaving it up the server to pick the 'best' 
>>values for you - which I guess in most (all other?) cases happen to be 
>>the maximum size.
> 
> 
> Right. The above was indeed the guiding principle back when I did the
> rsize/wsize negotiation for NFSv3 and NFSv2 for the binary mount code.
> 
> The NFS protocol specifies that the maximum values are there to tell you
> that the server will do short read/writes if you exceed these. However,
> the preferred values may correspond to a different 'sweet spot' for the
> server read and write implementations.

So does that mean that the binary mount options are doing the right 
thing, whereas the text mount options are not? Also, just to confirm, 
I'm using NFSv3.

Thanks

James Pearson
