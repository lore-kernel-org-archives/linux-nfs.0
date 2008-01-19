From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Understanding iostat-ms output
Date: Sat, 19 Jan 2008 07:51:20 -0500
Message-ID: <4791F248.9040904@RedHat.com>
References: <2a29d0a3c209d9488b0a3e8263c53e38@swip.net> <1200675753.7781.32.camel@heimdal.trondhjem.org> <6FBCD100-A02A-4CA5-8329-A801846B14BC@oracle.com> <1200679596.7781.37.camel@heimdal.trondhjem.org> <004A35A1-29F1-4C3E-AD1A-B42EEF5B8C22@oracle.com> <1200683992.13348.4.camel@heimdal.trondhjem.org> <89AD69AD-9039-42C7-992C-05E1908791DD@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"linux-nfs@vger.kernel.org list" <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752284AbYASMxd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Jan 2008 07:53:33 -0500
In-Reply-To: <89AD69AD-9039-42C7-992C-05E1908791DD@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Trond-
> 
> On Jan 18, 2008, at 2:19 PM, Trond Myklebust wrote:
>> On Fri, 2008-01-18 at 13:11 -0500, Chuck Lever wrote:
>>> The plan is to include these scripts in nfs-utils during 2CQ08, after
>>> the IPv6 work is complete.  There is some additional work to be done,
>>> such as composing man pages for both scripts, adding appropriate
>>> dependency information in the nfs-utils build scripts, and so on.
>>
>> I'm of two minds about that. I agree that we need an iostat-like utility
>> in nfs-utils, but I'm wary about also adding in a new language
>> dependency on python.
> 
> 
> Steve has already agreed to include the Python versions.  However, if it
> presents a challenge, it would be fairly trivial to rewrite these
> scripts in C.
Personally I think Python is fine... but let me look into it to how
painful the integration is and what dependencies are needed. 

steved.
