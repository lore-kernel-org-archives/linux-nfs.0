Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2120.oracle.com ([141.146.126.78]:36614 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728417AbeHFQzy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Aug 2018 12:55:54 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: noresvport and port re-use
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyGeq11izA3J6mfiCnEzg1NE_9z13unx6PDy8SNK_ahASg@mail.gmail.com>
Date: Mon, 6 Aug 2018 10:46:20 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9B79CDF3-838E-4E81-BE9C-0BB47E2FC404@oracle.com>
References: <CAN-5tyERJVoiUR3ub8yjMor3YYN5ksdd93dpKoW=4OkGw6OPpg@mail.gmail.com>
 <CAN-5tyGeq11izA3J6mfiCnEzg1NE_9z13unx6PDy8SNK_ahASg@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 2, 2018, at 12:42 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> 
> On Thu, Aug 2, 2018 at 11:14 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> Hi folks,
>> 
>> There is no documentation of this behavior but when "noresvport" is
>> specified, the client will not try to re-use the port upon connection
>> re-establishement. Is this an oversight or a desired behavior (ie.,
>> client doesn't need to be conservative and re-use ports)?
>> 
>> Thank you.
> 
> I'm going to speculate on the reason myself and would like to hear
> some folks thoughts.
> 
> When we specify "noresvport" we use port=0 value that tells the kernel
> - use any port. When connection is re-established port=0 so NFS has no
> control over which port the kernel will choose.
> 
> When client re-establishes the connection with a different port, that
> has an effect on the server's replay cache. Any thoughts on that?
> 
> Should the client remember which non-privileged port it used and then
> the next time request a specific port?

The basic constraint is that:

If the client actively disconnects, or if the client is using an NFSv4
session, then for a fresh connection the client is free to use any
available source port in the range selected by the "resvport" mount
option.

If there is no NFSv4 session and the server or the network transport
actively disconnects (say, due to a keep-alive timeout), the client
should attempt to use the same source port as the previous connection
in order to preserve DRC content on the server.


> Is that possible?


--
Chuck Lever



