Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17018 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752295Ab0JAH6s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 03:58:48 -0400
Message-ID: <4CA594B5.1090207@panasas.com>
Date: Fri, 01 Oct 2010 09:58:45 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: another block layout oops
References: <20100930171325.GA5731@merit.edu>	<4CA503C2.2090607@panasas.com>	<20100930215220.GB7244@merit.edu> <AANLkTi=bRwN3uoszG0jTzVSPMSwP6VKn+rW470uWwAj1@mail.gmail.com>
In-Reply-To: <AANLkTi=bRwN3uoszG0jTzVSPMSwP6VKn+rW470uWwAj1@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-01 04:14, Fred Isaman wrote:
> On Thu, Sep 30, 2010 at 5:52 PM, Jim Rees <rees@umich.edu> wrote:
>> Benny Halevy wrote:
>>
>>  Jim, would you mind retesting with pnfs-all-2.6.36-rc6-2010-09-30?
>>  Not that there's any possible fix there, but a fresh Oops could
>>  help, if you can reproduce it.
>>
>> Will do, probably after an important meeting I have at 6:00 this evening.
> 
> There is a problem with the LAYOUTGET error handling, which is
> probably what Jim is hitting  (the block servers are much more likely
> to send RETRYLATER).  I'll send in a fix tomorrow morning.

One problem I can see is that nfs4_layoutget_release frees calldata
(a.k.a. lgp) which is reused later if we retry.

We should either keep a reference count on it or clone it internally
in _nfs4_proc_layoutget for each call.  Since the calls are essentially
synchronous the caller and allocator (e.g. send_layoutget) can just
free the call data (or dereference, if we keep a refcount).

Same for layoutcommit and layoutreturn.

Benny


> 
> Fred
> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
