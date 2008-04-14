From: Peter Staubach <staubach@redhat.com>
Subject: Re: [PATCH] NFS: Only warn on unrecognized mount options
Date: Mon, 14 Apr 2008 13:19:29 -0400
Message-ID: <48039221.5020609@redhat.com>
References: <20080411200249.28007.12509.stgit@manray.1015granger.net> <1207945499.15646.11.camel@heimdal.trondhjem.org> <2832BD5F-D944-41FD-9FF1-1EC4D4DFA5E0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43848 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755617AbYDNRUp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Apr 2008 13:20:45 -0400
In-Reply-To: <2832BD5F-D944-41FD-9FF1-1EC4D4DFA5E0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Apr 11, 2008, at 4:24 PM, Trond Myklebust wrote:
>> On Fri, 2008-04-11 at 16:03 -0400, Chuck Lever wrote:
>>> To provide compatibility with automounters who use a common set of 
>>> mount
>>> options for all file systems, change the NFS in-kernel mount option 
>>> parser
>>> to ignore mount options it doesn't recognize.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> Yet another NFS mount patch!  Build tested only.  Comments?
>>>
>>> fs/nfs/super.c |    7 ++-----
>>> 1 files changed, 2 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>>> index f921902..a7201f0 100644
>>> --- a/fs/nfs/super.c
>>> +++ b/fs/nfs/super.c
>>> @@ -1044,7 +1044,8 @@ static int nfs_parse_mount_options(char *raw,
>>>             break;
>>>
>>>         default:
>>> -            goto out_unknown;
>>> +            printk(KERN_INFO "NFS: unrecognized mount option '%s'"
>>> +                    " ignored\n", p);
>>>         }
>>>     }
>>>
>>> @@ -1070,10 +1071,6 @@ out_unrec_xprt:
>>> out_unrec_sec:
>>>     printk(KERN_INFO "NFS: unrecognized security flavor\n");
>>>     return 0;
>>> -
>>> -out_unknown:
>>> -    printk(KERN_INFO "NFS: unknown mount option: %s\n", p);
>>> -    return 0;
>>> }
>>>
>>> /*
>>
>> This isn't really a very good solution either. Spamming the syslog on
>> every option that is being ignored isn't going to help the folks with
>> the global automounter maps. Either the rules should be that 'all
>> options are allowed' or they should be that 'only recognised NFS options
>> are allowed'.
>
>
> Despite what I posted last week, I like the code the way it is now:  
> We should reject any unrecognized mount options with an error 
> message.  Anything else invites subtle behavior problems, security 
> holes, or even the possibility of data corruption.
>
> Oracle databases, for example, do rely on "sync" mounts actually being 
> synchronous.  If you specify Kerberos security but misspell it, I 
> think you would want to know that you're not getting the security 
> level you expect.
>
> Can someone (maybe Peter) help me understand how exactly this makes 
> using an automounter problematic? 

Automounter tools like autofs tend to get their mount options from
global maps, stored in name or directory services like NIS or LDAP.
Many users will be running mixed environment networks, including
systems like Solaris, HP/UX, AIX, Linux, etc.  This means that the
automounter maps may include options which only make sense for
specific systems and aren't applicable to other systems.

One of the features of an automounting feature, other than the
centralized administration, which may or may not be a liability
in this situation, is dynamic mounting and umounting.  This keeps
unused file systems from causing a problem because they get umounted
and then less likely for an application to stumble into and hence,
keeping a dead or very slow server from causing needless delays
and problems.  This also means that the same file system may get
mounted and umounted many times during day.

If the kernel is to print a message every time that it sees an
option that it doesn't understand, than it is possible that many,
many messages could be printed, one for _each_ unknown option
_every time_ that the file system is mounted.

As Trond said, this could lead to spamming the syslog, which will
make it useless.  This might be useful if the unknown options could
be logged once, but logging each individual unknown option, each
time that the file system mounted, makes this much less than
desirable and could potentially lead to a denial of service attack.

The risks outweigh the benefits when viewed from the big picture.

       ps
