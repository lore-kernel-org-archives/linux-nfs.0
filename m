From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] SUNRPC: Ensure all transports set rq_xtime consistently
Date: Tue, 10 Jun 2008 15:39:40 -0400
Message-ID: <76bd70e30806101239y56f87882pae623588b7b7bc73@mail.gmail.com>
References: <20080606172037.14757.64893.stgit@manray.1015granger.net>
	 <20080606172224.14757.75565.stgit@manray.1015granger.net>
	 <1213124593.20459.23.camel@localhost>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Trond Myklebust" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.187]:24208 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbYFJTjn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 15:39:43 -0400
Received: by gv-out-0910.google.com with SMTP id e6so658890gvc.37
        for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2008 12:39:40 -0700 (PDT)
In-Reply-To: <1213124593.20459.23.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 10, 2008 at 3:03 PM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2008-06-06 at 10:22 -0700, Chuck Lever wrote:
>> The RPC client uses the rq_xtime field in each RPC request to
>> determine the
>> round-trip time of the request.  Currently, the rq_xtime field is
>> initialized by each transport just before it starts enqueing a request
>> to
>> be sent.  However, transports do not handle initializing this value
>> consistently; sometimes they don't initialize it at all.
>>
>> To make the measurement of request round-trip time consistent for all
>> RPC client transport capabilities, pull rq_xtime initialization into
>> the
>> RPC client's generic transport logic.  Now all transports will get a
>> standardized RTT measure automatically, from:
>>
>>   xprt_transmit()
>>
>> to
>>
>>   xprt_complete_rqst()
>
> Please resend as a _text_ patch. base64-encoded HTML isn't an acceptable
> format for patches...

Sorry, I didn't do that on purpose.  I posted this via 'stg mail', but
it looks like the gmail.com MTA converts these.  I will try a
different outgoing mail service.

-- 
Chuck Lever
