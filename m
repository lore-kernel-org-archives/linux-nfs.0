Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59934 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751811AbdHAP1u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Aug 2017 11:27:50 -0400
Subject: Re: [PATCH 1/1] autotools: install rpcbind to --sbindir.
To: NeilBrown <neilb@suse.com>,
        Michael Orlitzky <michael@orlitzky.com>,
        linux-nfs@vger.kernel.org
References: <20170728135253.24542-1-michael@orlitzky.com>
 <20170728135253.24542-2-michael@orlitzky.com>
 <ab9fa53d-8301-f6e8-50d5-0ccddd2dccb6@RedHat.com>
 <87efsvvp40.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <67dfec42-4d08-2aae-f290-70c05d20d86c@RedHat.com>
Date: Tue, 1 Aug 2017 11:27:49 -0400
MIME-Version: 1.0
In-Reply-To: <87efsvvp40.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/01/2017 01:22 AM, NeilBrown wrote:
> On Mon, Jul 31 2017, Steve Dickson wrote:
> 
>> On 07/28/2017 09:52 AM, Michael Orlitzky wrote:
>>> According to its own man page, the rpcbind program "can only be
>>> started by the super-user." On systems where a distinction is made, it
>>> therefore makes sense to install rpcbind to the autotools sbindir
>>> rather than the regular bindir where it is currently installed. This
>>> is accomplished by three small changes:
>>>
>>>   1. Move rpcbind from bin_PROGRAMS to sbin_PROGRAMS in Makefile.am.
>>>   2. Change @_bindir@ to @_sbindir@ in the rpcbind systemd service file.
>>>   3. Tell configure.ac that it should substitute the value of $sbindir
>>>      into @_sbindir@ instead of $bindir$ into @_bindir@.
>>>
>>> The rpcinfo tool remains where it is, in bindir, since unprivileged
>>> users are able to usefully run it. This avoids forcing maintainers to
>>> choose between two bad options: hiding rpcinfo from unprivileged
>>> users, or installing a useless rpcbind for them.
>>> ---
>>>  Makefile.am                | 3 ++-
>>>  configure.ac               | 6 +++---
>>>  systemd/rpcbind.service.in | 2 +-
>>>  3 files changed, 6 insertions(+), 5 deletions(-)
>> A couple things... You are  missing a Signed-off-by line
>>
>> Also I would like some more input from others about
>> changing the default install directory to sbin
>>
>> Anybody have a problem with this?
> 
> In SUSE we run
>   ./configure --bindir=/sbin .....
> for rpcbind.
> 
> So: no, we do not have a problem with this.  Nor do I personally.
> 
> This came up before in the thread starting
>   https://www.spinics.net/lists/linux-nfs/msg60349.html
> but didn't quite get resolved for some reason that I don't recall.It turns out commit 5739ac634 (Fix path for rpcbind in rpcbind.service)
move the rpcbind from sbindir to bindir and now this patch is
moving it back?? There is definitely some confusion here!

steved.
 
> 
> Thanks,
> NeilBrown
> 
>>
>> steved.
>>>
>>> diff --git a/Makefile.am b/Makefile.am
>>> index 43c2710..c160a95 100644
>>> --- a/Makefile.am
>>> +++ b/Makefile.am
>>> @@ -29,7 +29,8 @@ if LIBWRAP
>>>  AM_CPPFLAGS +=	-DLIBWRAP
>>>  endif
>>>  
>>> -bin_PROGRAMS = rpcbind rpcinfo
>>> +bin_PROGRAMS = rpcinfo
>>> +sbin_PROGRAMS = rpcbind
>>>  
>>>  rpcbind_SOURCES = \
>>>  	src/check_bound.c \
>>> diff --git a/configure.ac b/configure.ac
>>> index 3790310..359a418 100644
>>> --- a/configure.ac
>>> +++ b/configure.ac
>>> @@ -61,9 +61,9 @@ AC_SEARCH_LIBS([pthread_create], [pthread])
>>>  
>>>  AC_CHECK_HEADERS([nss.h rpcsvc/mount.h])
>>>  
>>> -# make bindir available for substitution in config file
>>> +# make sbindir available for substitution in config file
>>>  # 2 "evals" needed to expand variable names
>>> -AC_SUBST([_bindir])
>>> -AC_CONFIG_COMMANDS_PRE([eval eval _bindir=$bindir])
>>> +AC_SUBST([_sbindir])
>>> +AC_CONFIG_COMMANDS_PRE([eval eval _sbindir=$sbindir])
>>>  
>>>  AC_OUTPUT([Makefile systemd/rpcbind.service])
>>> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
>>> index 03a9e0b..f8cfa9f 100644
>>> --- a/systemd/rpcbind.service.in
>>> +++ b/systemd/rpcbind.service.in
>>> @@ -12,7 +12,7 @@ After=rpcbind.socket
>>>  [Service]
>>>  Type=notify
>>>  # distro can provide a drop-in adding EnvironmentFile=-/??? if needed.
>>> -ExecStart=@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
>>> +ExecStart=@_sbindir@/rpcbind $RPCBIND_OPTIONS -w -f
>>>  
>>>  [Install]
>>>  WantedBy=multi-user.target
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
