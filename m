From: Chuck Lever <Chuck.Lever@oracle.com>
Subject: Re: Understanding iostat-ms output
Date: Fri, 18 Jan 2008 16:06:58 -0500
Message-ID: <89AD69AD-9039-42C7-992C-05E1908791DD@oracle.com>
References: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net> <1200675753.7781.32.camel@heimdal.trondhjem.org> <6FBCD100-A02A-4CA5-8329-A801846B14BC@oracle.com> <1200679596.7781.37.camel@heimdal.trondhjem.org> <004A35A1-29F1-4C3E-AD1A-B42EEF5B8C22@oracle.com> <1200683992.13348.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: "linux-nfs@vger.kernel.org list" <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:56563 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762601AbYARVJP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 16:09:15 -0500
In-Reply-To: <1200683992.13348.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Jan 18, 2008, at 2:19 PM, Trond Myklebust wrote:
> On Fri, 2008-01-18 at 13:11 -0500, Chuck Lever wrote:
>> The plan is to include these scripts in nfs-utils during 2CQ08, after
>> the IPv6 work is complete.  There is some additional work to be done,
>> such as composing man pages for both scripts, adding appropriate
>> dependency information in the nfs-utils build scripts, and so on.
>
> I'm of two minds about that. I agree that we need an iostat-like  
> utility
> in nfs-utils, but I'm wary about also adding in a new language
> dependency on python.


Steve has already agreed to include the Python versions.  However, if  
it presents a challenge, it would be fairly trivial to rewrite these  
scripts in C.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
