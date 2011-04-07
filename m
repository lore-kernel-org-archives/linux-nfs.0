Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59366 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751576Ab1DGO3y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 10:29:54 -0400
Subject: Re: [PATCH v2 1/2] nfs-utils: mountd: Use a dynamic buffer for storing lists of gid's
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <A50602A820F61543B29992A418BB321B66E18F8A5E@seldmbx01.corpusers.net>
Date: Thu, 7 Apr 2011 10:29:39 -0400
Cc: "rees@umich.edu" <rees@umich.edu>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Message-Id: <5964B39E-ADFD-496C-98BE-D77920239E1B@oracle.com>
References: <20110405233552.GB27961@fieldses.org> <1302160948-5628-1-git-send-email-sean.finney@sonyericsson.com> <20110407122218.GA11897@merit.edu> <A50602A820F61543B29992A418BB321B66E18F8A5E@seldmbx01.corpusers.net>
To: "Finney, Sean" <Sean.Finney@sonyericsson.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Apr 7, 2011, at 10:15 AM, Finney, Sean wrote:

> Hi Jim,
> 
> On Thu, 2011-04-07 at 08:22 -0400, Jim Rees wrote:
> 
>> I was going to suggest you first call getgrouplist with groups set to 0 so
>> you can always alloc() the correct size list, but then I found this in the
>> man page:
>> 
>> BUGS
>>       In  glibc  versions  before  2.3.3, the implementation of this function
>>       contains a buffer-overrun bug: it returns the complete list  of  groups
>>       for  user  in  the array groups, even when the number of groups exceeds
>>       *ngroups.
> 
> Yuck.  The function is also not in POSIX or any other standards, so
> maybe it's worth discussing at a later point whether getgroups(2) would
> be a better interface to use, even if it means an extra step or two.

The standard RPC library function authunix_create_default() uses getgroups(2).  Take a look at the glibc version of this function to see the preferred method for using getgroups(2).

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




