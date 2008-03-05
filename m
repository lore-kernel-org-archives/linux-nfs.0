From: Gertjan Oude Lohuis <gertjan-DW70C6hi67U@public.gmane.org>
Subject: Re: Kernel 2.6.23.17 crash (Was: Kernel (2.6.24) crash on nfsd  (BUG:
 soft lockup))
Date: Wed, 05 Mar 2008 11:25:33 +0100
Message-ID: <47CE751D.4090301@byte.nl>
References: <47C434D2.80601@byte.nl> <47C50754.5030107@byte.nl> <47C50ABB.8050700@byte.nl> <Pine.LNX.4.62.0802281153040.31013@office2.c1.internal> <20080301163944.GC19927@fieldses.org> <20080301170322.GY6704@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Allard Hoeve <allard-DW70C6hi67U@public.gmane.org>, linux-nfs@vger.kernel.org,
	"Nilssen, Rune" <rune.nilssen-FJFKJQU35qU@public.gmane.org>
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw.c1.byte.nl ([82.94.214.64]:33446 "EHLO smtp.byte.nl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1764003AbYCEKZg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Mar 2008 05:25:36 -0500
In-Reply-To: <20080301170322.GY6704@kernel.dk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jens et al,

On 03/01/2008 06:03 PM, Jens Axboe wrote:
> On Sat, Mar 01 2008, J. Bruce Fields wrote:
>> So, the summary: several people are reporting soft lockup warnings with
>> _generic_file_splice_read as the latest or next-to-latest function on
>> the stack.  Sounds like 2.6.18 is good, various kernels around 2.6.23
>> and 2.6.24 are reported bad.  Is it possible this was a regression
>> introduced by the splice changes?
> 
> I posted this two days ago, but didn't get a reply back regarding if
> anyone who can reproduce tested it?
> 
> diff --git a/fs/splice.c b/fs/splice.c

<snip patch>

I'm sorry we didn't respond any earlier. We've been quite busy dividing 
our data over multiple fileservers to lower the load on the primary 
server, and in the process we downgraded the kernels on the NFS-servers 
to 2.6.22.19.
Since then we haven't seen another crash. My gut feeling says that the 
downgraded kernels were the 'solution', but it could also be that the 
lowered load has prevented the servers from crashing.

At the moment we won't be able to test your patch, simply because we 
can't afford any more crashes. However, if 2.6.22.19 does crash in the 
same way in the near future, I'll try your patch.

Thanks for your interest and help!

Regards,
Gertjan Oude Lohuis
