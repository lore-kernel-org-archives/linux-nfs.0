From: Peter Staubach <staubach@redhat.com>
Subject: Re: Should truncated READDIR replies return -EIO?
Date: Fri, 08 Feb 2008 10:42:05 -0500
Message-ID: <47AC784D.1020003@redhat.com>
References: <1202483082-5334-1-git-send-email-jlayton@redhat.com>	 <1202483596.8914.13.camel@heimdal.trondhjem.org> <1202483883.10337.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49765 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756783AbYBHPmP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Feb 2008 10:42:15 -0500
In-Reply-To: <1202483883.10337.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Fri, 2008-02-08 at 10:13 -0500, Trond Myklebust wrote:
>
>   
>> So whereas I agree that it might be correct to flag a READDIR reply that
>> contains no entries due to XDR encoding bugs, I'm not sure that we
>> should be flagging errors in the case where the XDR is correct.
>>     
>
> Another useful error change in the readdir code is that we may consider
> flagging an ENAMETOOLONG error instead of EIO in the cases where the
> filename is too large for us to parse.

This brings up another question that I've had -- how to correctly
differentiate between XDR decoding errors and issues having to do
with local implementation limitations.  I think that it would be
good to be able to make a determination, to properly know how to
do recovery from the situation.

    Thanx...

       ps
