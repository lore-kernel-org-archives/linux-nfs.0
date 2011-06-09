Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:55866 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab1FILtb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 07:49:31 -0400
Date: Thu, 9 Jun 2011 07:49:29 -0400
From: Jim Rees <rees@umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 87/88] Add configurable prefetch size for layoutget
Message-ID: <20110609114929.GA28157@merit.edu>
References: <cover.1307464381.git.rees@umich.edu>
 <09142112ff0115f7f22124a69ead7b9bb5e0958f.1307464382.git.rees@umich.edu>
 <4DEED80A.4000102@panasas.com>
 <20110608021852.GA20998@merit.edu>
 <BANLkTi=HcQcGbTKTq2MSg8XeW=fKwG4-tw@mail.gmail.com>
 <4DF062D6.7010304@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4DF062D6.7010304@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Benny Halevy wrote:

  >> But note that this patch doesn't change anything unless you set the sysctl.
  > there is a default value of 2M. maybe we can set it to page size by
  > default so other layout are not affected and block layout can let
  > users set it by hand if they care about performance. does this make
  > sense?
  
  If doing it at all why use a sysctl rather than a mount option?
  Or maybe coding the logic for prefetching the layout iff sequential
  access is detected is the right thing to do.

I would rather see some automatic solution than to add either a sysctl or a
mount option.  For now you can just drop that patch, as it's not needed for
basic pnfs block.

My understanding is that layoutget specifies a min and max, and the server
is returning the min.  Trond and Fred believe this should be fixed on the
server.  Here's the original report of the problem:

From: Bergwolf

>From the network trace for pnfs, we can see the root cause for slow performance
is too many small layoutget. In specific, client asks for a layout of only 4K
pagesize (and server returns 8K due to block size alignment) at each time.

The total IO time is 256/1.68 = 152 second.
There are 256*1024/8 = 32768 layoutget for the 256MB file.
On average, the time spent on each layoutget is 0.00456 second according to the
trace.
The total layoutget time is 32768* 0.00456 = 149 second, which takes up about
98% of total IO time.

So we should optimize layoutget's granularity to get better performance. For
instance, use a configurable prefetch size of 2MB or so.
