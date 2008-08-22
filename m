From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Fri, 22 Aug 2008 14:25:58 -0400
Message-ID: <76bd70e30808221125n42e93bf1i1e19685b57144dce@mail.gmail.com>
References: <20080820200827.GC21226@fieldses.org>
	 <76bd70e30808201419g5171d7eob7e6b57dd735e07d@mail.gmail.com>
	 <20080820212902.GH21226@fieldses.org>
	 <76bd70e30808201507l44c85d08o3ec4e8eeb7edda5e@mail.gmail.com>
	 <20080820233024.GC28617@fieldses.org>
	 <76bd70e30808201900r699ca044o884584ecedc6a799@mail.gmail.com>
	 <20080821204620.GD29466@fieldses.org>
	 <76bd70e30808211522k7cb6846fs4e371c8003320fe7@mail.gmail.com>
	 <20080821225413.GD4076@fieldses.org>
	 <76bd70e30808211605j3c32cc44v440c19e5fe81bdc9@mail.gmail.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.186]:33891 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549AbYHVS0A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 14:26:00 -0400
Received: by mu-out-0910.google.com with SMTP id w8so767985mue.1
        for <linux-nfs@vger.kernel.org>; Fri, 22 Aug 2008 11:25:58 -0700 (PDT)
In-Reply-To: <76bd70e30808211605j3c32cc44v440c19e5fe81bdc9-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2008 at 7:05 PM, Chuck Lever <chucklever@gmail.com> wrote:
> On Thu, Aug 21, 2008 at 6:54 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> On Thu, Aug 21, 2008 at 06:22:02PM -0400, Chuck Lever wrote:
>>> I don't think you want to add a lot of specialized logic in
>>> nfs4namespace.c or client.c or where ever that has to figure out what
>>> a valid IP address string looks like.  Just hand the referral hostname
>>> string to the super.c address parser.  That's what it's there for.
>>>
>>> If something comes out, it's almost sure to be a valid address.  If
>>> you have a scope ID too, then it's unsupported for now, and punt.  You
>>> can also explicitly check for a link-local address (there is a
>>> facility for that) and punt in that case too.
>>
>> The case where the scope id is bad or the kstrndup() in
>> nfs_parse_ipv6_scope_id fails seems to be indistinguishable from the
>> case where there is no scope id specified.
>
> This sounds like nfs_parse_ipv6_scope_id() is broken.  You mean if the
> hostname just ends with a '%' ?

I just sent you a patch that should address this issue.  Compile-tested only.

-- 
Chuck Lever
