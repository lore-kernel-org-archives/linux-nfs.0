From: "david m. richter" <richterd@gmail.com>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Sat, 10 May 2008 21:07:23 -0400
Message-ID: <1d07ca700805101807s7c034b08sc531993aa81010b2@mail.gmail.com>
References: <20080509011918.GK12690@fieldses.org>
	 <1210309839.8657.0.camel@localhost>
	 <20080509152750.GA325@fieldses.org>
	 <20080509165204.GB1907@fieldses.org>
	 <20080509171208.GC1907@fieldses.org>
	 <20080509235930.GM1907@fieldses.org>
	 <C4A41609-740F-450E-BE8F-7F51A8A9327B@oracle.com>
	 <1210440728.12927.5.camel@localhost>
	 <5FE6354F-8E28-4697-A27D-8532FD547683@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, "Manoj Naik" <manoj@almaden.ibm.com>
To: "Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:44817 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbYEKBHY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 May 2008 21:07:24 -0400
Received: by rv-out-0506.google.com with SMTP id l9so2136136rvb.1
        for <linux-nfs@vger.kernel.org>; Sat, 10 May 2008 18:07:23 -0700 (PDT)
In-Reply-To: <5FE6354F-8E28-4697-A27D-8532FD547683@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 10, 2008 at 7:50 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
> On May 10, 2008, at 10:32 AM, Trond Myklebust wrote:
>>
>> On Fri, 2008-05-09 at 19:29 -0700, Chuck Lever wrote:
>>>
>>> Should you use in4_pton() instead?
>>
>> Can we rather convert this to use nfs_parse_server_address? We don't
>> need 10 different ways to parse text addresses...
>
> I'm OK with that, as long as there isn't a technical problem with using
> in4_pton().

nfs_parse_server_address() uses in4_pton(), it just also groks ipv6.

> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
