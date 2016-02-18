Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwkm04.jp.fujitsu.com ([202.219.69.171]:10093 "EHLO
	mgwkm04.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423543AbcBRDyQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Feb 2016 22:54:16 -0500
Subject: Re: call_usermodehelper in containers
To: "Eric W. Biederman" <ebiederm@xmission.com>, Ian Kent <raven@themaw.net>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
 <20131112004703.GB15377@kroah.com>
 <20131112061201.04cf25ab@tlielax.poochiereds.net>
 <528226EC.4050701@parallels.com>
 <20131112083043.0ab78e67@tlielax.poochiereds.net>
 <5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
 <20131118172844.GA10005@redhat.com> <1455149857.2903.9.camel@themaw.net>
 <8737sq4teb.fsf@x220.int.ebiederm.org>
Cc: Oleg Nesterov <oleg@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bfields@fieldses.org,
        bharrosh@panasas.com,
        Linux Containers <containers@lists.linux-foundation.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56C53DE3.1070108@jp.fujitsu.com>
Date: Thu, 18 Feb 2016 12:43:31 +0900
MIME-Version: 1.0
In-Reply-To: <8737sq4teb.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset=iso-2022-jp
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016/02/18 11:57, Eric W. Biederman wrote:
> 
> Ccing The containers list because a related discussion is happening there
> and somehow this thread has never made it there.
> 
> Ian Kent <raven@themaw.net> writes:
> 
>> On Mon, 2013-11-18 at 18:28 +0100, Oleg Nesterov wrote:
>>> On 11/15, Eric W. Biederman wrote:
>>>>
>>>> I don't understand that one.  Having a preforked thread with the
>>>> proper
>>>> environment that can act like kthreadd in terms of spawning user
>>>> mode
>>>> helpers works and is simple.
>>
>> Forgive me replying to such an old thread but ...
>>
>> After realizing workqueues can't be used to pre-create threads to run
>> usermode helpers I've returned to look at this.
> 
> If someone can wind up with a good implementation I will be happy.
> 
>>> Can't we ask ->child_reaper to create the non-daemonized kernel thread
>>> with the "right" ->nsproxy, ->fs, etc?
>>
>> Eric, do you think this approach would be sufficient too?
>>
>> Probably wouldn't be quite right for user namespaces but should provide
>> what's needed for other cases?
>>
>> It certainly has the advantage of not having to maintain a plague of
>> processes waiting around to execute helpers.
> 
> That certainly sounds attractive.  Especially for the case of everyone
> who wants to set a core pattern in a container.
> 
> I am fuzzy on all of the details right now, but what I do remember is
> that in the kernel the user mode helper concepts when they attempted to
> scrub a processes environment were quite error prone until we managed to
> get kthreadd(pid 2) on the scene which always had a clean environment.
> 
> If we are going to tie this kind of thing to the pid namespace I
> recommend simplying denying it if you are in a user namespace without
> an approrpriate pid namespace.  AKA simply not allowing thigns to be setup
> if current->pid_ns->user_ns != current->user_ns.
> 
Can't be handled by simple capability like CAP_SYS_USERMODEHELPER ?

User_ns check seems not to allow core-dump-cather in host will not work if user_ns is used.

Thanks,
-Kame

