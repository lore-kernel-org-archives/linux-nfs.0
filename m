Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:53081 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab1G0Da1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 23:30:27 -0400
Received: by qyk9 with SMTP id 9so684848qyk.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 20:30:26 -0700 (PDT)
Subject: Re: [Libtirpc-devel] [PATCH] Autofs configure fails to detect IPv6 when libtirpc is enabled
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <1311734445.3473.19.camel@perseus.themaw.net>
Date: Tue, 26 Jul 2011 23:30:22 -0400
Cc: Steve Dickson <SteveD@redhat.com>,
        autofs mailing list <autofs@linux.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Libtirpc Devel List <libtirpc-devel@lists.sourceforge.net>
Message-Id: <8A86A2AE-A1C7-473E-931A-CF03BD690CE6@gmail.com>
References: <1311683346-16881-1-git-send-email-steved@redhat.com> <8A84CF7D-9579-4645-AE5D-FE8358F466C0@gmail.com> <4E2F2DE6.5030500@RedHat.com>  <1311728231.3473.7.camel@perseus.themaw.net> <1311729784.3473.14.camel@perseus.themaw.net> <A8F3853A-9C75-4F65-8EEB-88DD13C3FF9B@gmail.com> <1311734445.3473.19.camel@perseus.themaw.net>
To: Ian Kent <ikent@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 26, 2011, at 10:40 PM, Ian Kent wrote:

> On Tue, 2011-07-26 at 22:09 -0400, Chuck Lever wrote:
>> On Jul 26, 2011, at 9:23 PM, Ian Kent wrote:
>> 
>>> On Wed, 2011-07-27 at 08:57 +0800, Ian Kent wrote:
>>>> On Tue, 2011-07-26 at 17:13 -0400, Steve Dickson wrote:
>>>>> 
>>>>> On 07/26/2011 10:50 AM, Chuck Lever wrote:
>>>>>> 
>>>>>> On Jul 26, 2011, at 2:29 PM, Steve Dickson wrote:
>>>>>> 
>>>>>>> From: Ian Kent <raven@themaw.net>
>>>>>>> 
>>>>>>> The IPv6 client functions clntudp6_bufcreate(), clntudp6_create and
>>>>>>> clnttcp6_create and the server functions svcudp6_bufcreate(),
>>>>>>> svctcp6_create() and svcudp6_create() are not included in the library
>>>>>>> whe libtirpc is built.
>>>>>> 
>>>>>> Are these part of the libtirpc standard API?  I'm not sure why we would need them if, say, Solaris does not support these.
>>>>> It appears they are not since they are not mentioned the man pages.....
>>>>> But, at least in the autofs code, they are expected
>>>>>  https://bugzilla.redhat.com/show_bug.cgi?id=711956#c0
>>>>> 
>>>>> Ian, where else are these routines defined? 
>>>> 
>>>> Now that I look I can't find the original source tar that was used for
>>>> libtirpc, thought I had it.
>>> 
>>> Found what I had.
>>> 
>>> AFAICT what I think was the original source doesn't have any IPv6 code
>>> that I can see.
>>> 
>>> Worse, these functions were excluded with the "#ifdef INET6_NOT_USED"
>>> macro as far back as libtirpc version 0.1.5 so, my bad, sorry.
>>> 
>>>> 
>>>> The story is that long ago when I changed autofs to use libtirpc (to
>>>> make it ready for IPv6) I found these functions in the source and they
>>>> were (obviously) the IPv6 counterparts for the corresponding IPv4
>>>> functions which I was already using, so I used them. It took me quite a
>>>> while to realize my code wasn't working and then I found that somewhere
>>>> along the line they have been excluded, oops!
>>>> 
>>>> If there are to be no IPv6 counterparts for the corresponding IPv4
>>>> functions which functions should I use then?
>>> 
>>> So what can I use?
>>> 
>>> It seems to me that these functions would be useful for people porting
>>> code that uses the corresponding IPv4 functions so could we define them
>>> please. At some point someone must have had that same idea ....
>> 
>> It looks to me like these functions were part of an original attempt
>> at IPv6 support that was abandoned long ago.  They are not part of
>> TI-RPC, but as you observed, they are merely IPv6 versions of the
>> legacy RPC API. I don't see these implemented in glibc, for example.
>> 
>> For IPv6 support, use functions that are part of the modern libtirpc
>> API.  This is described in Sun doc 816-1435.  You probably will be
>> most successful with the "simplified interface" which is described in
>> Chapter 4. You might need somewhat more extensive surgery since I'm
>> guessing you have separate code paths to invoke the IPv4 and IPv6
>> legacy RPC functions; generally speaking that should not be needed
>> when using the libtirpc API.
> 
> I doubt the simplified interface will be adequate since this code was
> written because of a need for greater control over timeouts. Perhaps
> that won't be the case, I don't know yet.

If you want control over connection timeouts, use the expert-level or bottom-level interfaces.  Otherwise you can set per-RPC timeouts when clnt_call(3t) is invoked.  nfs-utils has some example code (support/nfs/rpc_socket.c is one place to look).

> Your suggestion amounts to saying I need to re-write all my RPC code.

The substantial change with client-side TI-RPC is how CLIENTs are created.  The other RPC operations are similar or the same as they were with the legacy API.  Once you get over getnetconfigent(3t) it's really not as bad as it looks.

