From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: Understanding iostat-ms output
Date: Fri, 18 Jan 2008 13:11:25 -0500
Message-ID: <004A35A1-29F1-4C3E-AD1A-B42EEF5B8C22@oracle.com>
References: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net> <1200675753.7781.32.camel@heimdal.trondhjem.org> <6FBCD100-A02A-4CA5-8329-A801846B14BC@oracle.com> <1200679596.7781.37.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "linux-nfs@vger.kernel.org list" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:37569 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761198AbYARSNd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 13:13:33 -0500
In-Reply-To: <1200679596.7781.37.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jan 18, 2008, at 1:06 PM, Trond Myklebust wrote:
> On Fri, 2008-01-18 at 12:37 -0500, Chuck Lever wrote:
>> I've applied Trond's patch, and patches from NetApp to support RDMA
>> statistics to these two scripts, and posted fresh versions here:
>>
>>    http://oss.oracle.com/~cel/linux-2.6/2.6.24/
>
> Any chance you could put this in a git repository on git.linux-nfs.org
> so that we can track changes?


The plan is to include these scripts in nfs-utils during 2CQ08, after  
the IPv6 work is complete.  There is some additional work to be done,  
such as composing man pages for both scripts, adding appropriate  
dependency information in the nfs-utils build scripts, and so on.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
