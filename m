From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH 2/4] NFS: Support raw IPv6 address hostnames during NFS
 mount	operation
Date: Wed, 18 Jun 2008 18:59:03 -0400
Message-ID: <48599337.1070502@redhat.com>
References: <20080618222951.16006.3679.stgit@ellison.1015granger.net>	 <20080618223203.16006.61765.stgit@ellison.1015granger.net>	 <48598DB7.4060404@redhat.com>  <48598F59.2040505@oracle.com> <1213829515.25182.78.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: chuck.lever@oracle.com, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:32784 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299AbYFRXAS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Jun 2008 19:00:18 -0400
In-Reply-To: <1213829515.25182.78.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Wed, 2008-06-18 at 18:42 -0400, Chuck Lever wrote:
>   
>> Peter Staubach wrote:
>>     
>>> It seems unfortunate that the convention couldn't have been to
>>> look for the first instance of ":/" and break the strings there.
>>>       
>> I wonder if you can ever specify an export path that does not begin with 
>> a '/' -- is that possible when mounting an NFS server that exports, say, 
>> an old-fashioned HFS volume?
>>     
>
> It is quite legal to specify a path that doesn't start with '/':
> NFSv2/v3 mount servers will, for instance, just implicitly assume it.
> For that reason, there were user complaints the last time we started
> requiring the '/' and returning an error when it wasn't supplied.

And, hence, the [] syntax...  :-)

       ps
