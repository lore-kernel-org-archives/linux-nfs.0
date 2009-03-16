From: Greg Banks <gnb@sgi.com>
Subject: Re: [patch 3/3] knfsd: add file to export stats about nfsd pools
Date: Mon, 16 Mar 2009 14:21:02 +1100
Message-ID: <49BDC59E.9040406@sgi.com>
References: <20090113102633.719563000@sgi.com> <20090113102653.884405000@sgi.com> <20090212171106.GB21445@fieldses.org> <499CFF69.3000708@sgi.com> <20090315212534.GC27568@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:56057 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753555AbZCPDQU (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Sun, 15 Mar 2009 23:16:20 -0400
In-Reply-To: <20090315212534.GC27568@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Feb 19, 2009 at 05:42:49PM +1100, Greg Banks wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Tue, Jan 13, 2009 at 09:26:36PM +1100, Greg Banks wrote:
>>>   
>>>       
>>> As you said, an important question for the sysadmin is "should I
>>> configure more nfsds?"  How do they answer that?
>>>   
>>>       
>> You can work that out, [...]
>>     
>
> OK, thanks, that makes sense, but: it would be really fantastic if we
> could update and/or replace some of the howto's and faq's that are out
> there.  

Fair enough.

After I composed the above reply, I wondered whether the right thing to
do would have been to add that text to a new file somewhere in
Documentation/.  Would that suit as an interim measure while I look at
howtos and faqs?  I mention this because I'll be adding more new stats
in the next tranche of patches.
>
> Queued up this and the old-stats removal for 2.6.30.
>   

Thanks.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

