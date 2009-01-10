From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [patch 10/14] sunrpc: Reorganise the queuing of cache upcalls.
Date: Sat, 10 Jan 2009 12:28:38 +1100
Message-ID: <4967F9C6.1070204@melbourne.sgi.com>
References: <20090108082510.050854000@sgi.com> <20090108082604.517918000@sgi.com> <20090108195747.GB19312@fieldses.org> <4966B92F.8060008@melbourne.sgi.com> <20090109025716.GA25831@fieldses.org> <4966C0AB.7000604@melbourne.sgi.com> <9D49048E-5F75-42A3-99C9-319A54010E64@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS ML <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:47898 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756293AbZAJBgd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Jan 2009 20:36:33 -0500
In-Reply-To: <9D49048E-5F75-42A3-99C9-319A54010E64@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Jan 8, 2009, at Jan 8, 2009, 10:12 PM, Greg Banks wrote:
>>
>> a) support partial reads but do so properly: [...]
>>
>> b) don't support partial reads but require userspace to do larger full
>> reads.  I don't think 100K is too much to ask.
>
> How about:
>
> c) Use an mmap like API to avoid copying 100K of data between user
> space and kernel.

I think that would be a significant complexity hit, and even at 100K the
size of the data just doesn't warrant it.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

