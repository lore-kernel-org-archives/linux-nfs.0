From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/8] SUNRPC: Set V6ONLY socket option for RPC listener sockets
Date: Thu, 21 Aug 2008 12:20:53 -0400
Message-ID: <76bd70e30808210920y3db1b07cyccbe40e1b4582c12@mail.gmail.com>
References: <20080813223653.13068.9467.stgit@manray.1015granger.net>
	 <20080813223953.13068.97829.stgit@manray.1015granger.net>
	 <20080814200554.GI23859@fieldses.org>
	 <74E488BD-DB15-41CD-AD30-A8A5213BC140@oracle.com>
	 <20080814203833.GK23859@fieldses.org>
	 <A8AF0C9D-B606-4EA4-9EE0-5367C515BE84@oracle.com>
	 <20080820193126.GB21226@fieldses.org> <48AD5B85.4020807@bull.net>
	 <20080821144117.GB22587@fieldses.org> <48AD8A72.2040200@bull.net>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	trond.myklebust@netapp.com, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org, "Frank S Filz" <ffilz@us.ibm.com>
To: aime.le-rouzic@bull.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:60991 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbYHUQUz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Aug 2008 12:20:55 -0400
Received: by yx-out-2324.google.com with SMTP id 8so31617yxm.1
        for <linux-nfs@vger.kernel.org>; Thu, 21 Aug 2008 09:20:54 -0700 (PDT)
In-Reply-To: <48AD8A72.2040200@bull.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2008 at 11:32 AM, Le Rouzic <aime.le-rouzic@bull.net> w=
rote:
> J. Bruce Fields a =E9crit :
>
>>> J. Bruce Fields a =E9crit :
>>>
>>>>>>
>>>>>> so suppose I'm a server
>>>>>> administrator, and want my nfs server to listen for ipv6 connect=
ions.
>>>>>> Will there be some switch I'll need to flip?
>>>>>>
>>
>>
>>>>
>>>> On Thu, Aug 14, 2008 at 04:45:31PM -0400, Chuck Lever wrote:
>>>>
>>>>>
>>>>> I don't know how that UI will be designed.  So far, I've focused =
only
>>>>> on the pieces needed for client side IPv6 support.  I figured the=
 Bull team
>>>>> had something figured out for the server, and didn't think any mo=
re about
>>>>> it.
>>>>>
>>>>
>>>> I've forgotten who was working on that; Aurelien Charbon?
>>>>
>>
>> On Thu, Aug 21, 2008 at 02:11:49PM +0200, Le Rouzic wrote:
>>
>>>
>>> Sorry for not answering before, I am back from vacation.  Aurelien =
is
>>> no longer directly working on that even he can answer any  question=
s.
>>> It is me now who tess NFSV4 IPV6 with the patches Aurelien delivere=
d
>>> to Bruce a few months ago.  But since Chuck has delivered several n=
ew
>>> patches which affect the NFS server side about the way nfsd can lis=
ten
>>> for ipv6 connections.
>>>
>>
>> I merged the last patch I can remember from Aurelien (f15364bd "IPv6
>> support for NFS server export caches").  Are there some others float=
ing
>> around that I should look at?
>>
>>
>>>
>>> To have NFSV4 IPV6 working with those changes, what it would be nic=
e
>>> to have a complete list on what are the changes.  Is there now a
>>> complete release for which we can test those latest  changes? If no=
t
>>> which one will be?  Are there any other changes still planned?
>>>
>>
>> I was hoping you or Chuck would know; I don't know of anyone else
>> working on nfs over ipv6.
>>
>
>  Hi,
> About changes I was talking about changes introduced for IPv6 RPC ser=
vices
> via rpcbind
> at least thoses published on the 19th on this mailing list can be con=
sidered
> like the last ones.

My complete IPv6 patch set is available here:

  http://git.linux-nfs.org/?p=3Dcel/cel-2.6.git;a=3Dsummary

The tags that start "cel-ipv6-..." contain the IPv6-related patches.
I see the latest one is still two weeks old, so I should update it
with what I sent to Bruce recently.

--=20
Chuck Lever
