From: Fred Isaman <iisaman@netapp.com>
Subject: Re: another block layout oops
Date: Fri, 1 Oct 2010 12:45:30 -0400
Message-ID: <AANLkTi=T6PY6MDzbyWikSYOi7HoMWAsEarw-3k=S1+Bu@mail.gmail.com>
References: <20100930171325.GA5731@merit.edu>
	<4CA503C2.2090607@panasas.com>
	<20100930215220.GB7244@merit.edu>
	<AANLkTi=bRwN3uoszG0jTzVSPMSwP6VKn+rW470uWwAj1@mail.gmail.com>
	<4CA594B5.1090207@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org,
	peter honeyman <honey@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36665 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab0JAQpc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 12:45:32 -0400
Received: by bwz11 with SMTP id 11so2313885bwz.19
        for <linux-nfs@vger.kernel.org>; Fri, 01 Oct 2010 09:45:31 -0700 (PDT)
In-Reply-To: <4CA594B5.1090207@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim, does the recently submitted PATCH 5/7 fix this?

=46red

On Fri, Oct 1, 2010 at 3:58 AM, Benny Halevy <bhalevy@panasas.com> wrot=
e:
> On 2010-10-01 04:14, Fred Isaman wrote:
>> On Thu, Sep 30, 2010 at 5:52 PM, Jim Rees <rees@umich.edu> wrote:
>>> Benny Halevy wrote:
>>>
>>> =A0Jim, would you mind retesting with pnfs-all-2.6.36-rc6-2010-09-3=
0?
>>> =A0Not that there's any possible fix there, but a fresh Oops could
>>> =A0help, if you can reproduce it.
>>>
>>> Will do, probably after an important meeting I have at 6:00 this ev=
ening.
>>
>> There is a problem with the LAYOUTGET error handling, which is
>> probably what Jim is hitting =A0(the block servers are much more lik=
ely
>> to send RETRYLATER). =A0I'll send in a fix tomorrow morning.
>
> One problem I can see is that nfs4_layoutget_release frees calldata
> (a.k.a. lgp) which is reused later if we retry.
>
> We should either keep a reference count on it or clone it internally
> in _nfs4_proc_layoutget for each call. =A0Since the calls are essenti=
ally
> synchronous the caller and allocator (e.g. send_layoutget) can just
> free the call data (or dereference, if we keep a refcount).
>
> Same for layoutcommit and layoutreturn.
>
> Benny
>
>
>>
>> Fred
>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
