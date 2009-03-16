From: Greg Banks <gnb@sgi.com>
Subject: Re: [patch 2/3] knfsd: avoid overloading the CPU scheduler with	enormous
 load averages
Date: Mon, 16 Mar 2009 14:10:06 +1100
Message-ID: <49BDC30E.7000508@sgi.com>
References: <20090113102633.719563000@sgi.com> <20090113102653.664553000@sgi.com> <20090211231033.GK27686@fieldses.org> <499CFB6B.1010902@sgi.com> <20090315212112.GB27568@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:59655 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753692AbZCPDFZ (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Sun, 15 Mar 2009 23:05:25 -0400
In-Reply-To: <20090315212112.GB27568@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Feb 19, 2009 at 05:25:47PM +1100, Greg Banks wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Tue, Jan 13, 2009 at 09:26:35PM +1100, Greg Banks wrote:  
>>>       
>>> [...]
>>> It's a simple enough patch, but without any suggestion for how to retest
>>> on a more recent kernel, I'm uneasy.
>>>       
>> [...]
>>
>> Does that make you less uneasy?
>>     
>
> Yes, thanks!
>
> Queued up for 2.6.30, barring objections. 
Thanks.
>  But perhaps we should pass on
> the patch and your results to people who know the scheduler better and
> see if they can explain e.g. the loadavg numbers.
>   
If you like.  Personally I'm happy with assuming that it's because nfsd
is putting an unnaturally harsh load on the scheduler.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

