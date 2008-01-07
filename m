From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/4] NLM: Introduce completion function to match nlmclnt_init
Date: Mon, 7 Jan 2008 18:04:03 -0500
Message-ID: <AB3076F8-4E4F-4862-A47E-5917BFBB702B@oracle.com>
References: <20071220200405.3358.54150.stgit@manray.1015granger.net> <1199397248.1913.15.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:23159 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753928AbYAGXE4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2008 18:04:56 -0500
In-Reply-To: <1199397248.1913.15.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Jan 3, 2008, at 4:54 PM, Trond Myklebust wrote:
> On Thu, 2007-12-20 at 15:04 -0500, Chuck Lever wrote:
>> Introduce the other book-end for nlmclnt_init(). This function is  
>> invoked
>> by the NFS client during unmount processing to release the  
>> nlm_host struct
>> that was pinned by nlmclnt_init() during mount processing.
>
> Does this really need to be a separate patch from the nlmclnt_init?
>
> Furthermore, those EXPORT_SYMBOL() should really be EXPORT_SYMBOL_GPL.
> We don't want to make this an official ABI.

Should I change nlmclnt_proc() to use EXPORT_SYMBOL_GPL then?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
