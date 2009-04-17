From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [RFC 0/4] nfs-utils: nfsd support for minor version
Date: Fri, 17 Apr 2009 19:40:37 +0300
Message-ID: <49E8B105.7020007@panasas.com>
References: <49E2F6E4.2080501@panasas.com> <49E769C5.6010902@RedHat.com> <49E7721E.2070601@panasas.com> <49E7753C.4010300@RedHat.com> <20090416182313.GE450@fieldses.org> <49E7809B.2020002@RedHat.com> <20090416191826.GC1145@fieldses.org> <49E87798.8090308@RedHat.com> <C6A23BE1-A7F6-4FD6-B9E7-8E8CC4D09418@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS mailing list <pnfs@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:32980 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753158AbZDQQku (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2009 12:40:50 -0400
In-Reply-To: <C6A23BE1-A7F6-4FD6-B9E7-8E8CC4D09418@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 17, 2009, 19:18 +0300, Chuck Lever <chuck.lever@oracle.com> wrote:
> On Apr 17, 2009, at 8:35 AM, Steve Dickson wrote:
>> J. Bruce Fields wrote:
>>> On Thu, Apr 16, 2009 at 03:01:47PM -0400, Steve Dickson wrote:
>>>> I do get your point, but as we did with the initial v4 support,
>>>> having the support on by default and then having away to turn it
>>>> off is the correct approach... IMHO...
>>> I'd prefer it be off by default, for the obvious safety reasons.   
>>> (It's
>>> under rapid development and particularly likely to have bugs).  The  
>>> only
>>> reason we had it on by default before was that we didn't add the
>>> switching mechanism early enough.  (Well, and because we could keep  
>>> it
>>> off in the config.  But I'd rather be able to ship users a kernel  
>>> that
>>> supports 4.1 and give them the option of turning it on at runtime,  
>>> than
>>> make them build a new kernel.)
>> I agree with not making people recompile kernels, which is the whole
>> purpose behind the Fedora repos, but do I think you might be a bit
>> too cautious with exposing the technology.
>>
>> One, I've been running the kernels with everything enabled for a while
>> now with no problems whatsoever... A few scary looking warnings now  
>> and
>> then but nothing major. I also spent the majority of my time at  
>> Connectathon
>> this years testing with kernel that were fully enabled. Not one  
>> problem
>> WRT regression testing. Plus there is no better way to expose  
>> regression
>> problems (early on) than to enable the code.. IMHO...
>>
>> Second, its my understanding that clients have to explicitly  ask
>> for 4.1 support. Are there any client out there that default to
>> 4.1 support? I would think not since there is only one client out  
>> there
>> that defaults to V4.0. If there is a client that defaults to 4.1,  
>> then we
>> will a knob to turn that support off.
> 
> That might even be OK for Fedora-based NFS servers.  I think what you  
> are driving at is erring on the side of increasing the testing base.
> 
> For an enterprise distribution, however, I suggest following the  
> experience of proprietary storage vendors who enabled their NFSv4.0  
> implementation early, and were bitten hard by that decision.  They are  
> still dealing with the bad press.
> 
> 4.1 support should be left turned off by default, or disabled  
> entirely, in enterprise distributions until we have a high degree of  
> confidence that 4.1 doesn't open security or data integrity exposures,  
> and that the feature set is stable.  Perhaps you could provide a  
> "technology preview" release of RHEL 6 with NFSv4.1 enabled, just as  
> was done with FScache in earlier RHEL releases?

That sounds like a good compromise to me.

Benny

> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
