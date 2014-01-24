Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vb0-f44.google.com ([209.85.212.44]:38906 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750769AbaAXRBX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Jan 2014 12:01:23 -0500
Received: by mail-vb0-f44.google.com with SMTP id f12so2009185vbg.31
        for <linux-nfs@vger.kernel.org>; Fri, 24 Jan 2014 09:01:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140124114029.362028c3@tlielax.poochiereds.net>
References: <CAMFqqRrJPZVz6MPyDH45aQUsL4Jt-5HgMG9PfaLT6nCwdJk8fQ@mail.gmail.com>
	<CAMFqqRoh52UrGX2CCfuw0ij-7O7OfY_=a_DnHwrGaT+9OqBa+g@mail.gmail.com>
	<20140124114029.362028c3@tlielax.poochiereds.net>
Date: Fri, 24 Jan 2014 12:01:22 -0500
Message-ID: <CAMFqqRrV8R-gOpYHXXbP3DWHNcwmoaV-JMCeMMMQjZqis7jVLw@mail.gmail.com>
Subject: Re: NFS4: new accounts username = nobody, old accounts fine, reboot fine.
From: Stephen Cousins <steve.cousins@maine.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 24, 2014 at 11:40 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Fri, 24 Jan 2014 11:02:14 -0500
> Stephen Cousins <steve.cousins@maine.edu> wrote:
>
>> I have the following:
>>
>> File Server: CentOS 6.3 kernel 2.6.32-279.19.1.el6.x86_64
>> Head Node:   CentOS 5.7 kernel 2.6.18-275.12.1.el5.573g0000
>> Backup1:     CentOS 6.5 kernel 2.6.32-431.3.1.el6.x86_64
>> GPU:         CentOS 6.4 kernel 2.6.32-358.6.2.el6.x86_64
>>
>>
>> Booting up all machines after the file server is up works fine. All
>> ID's map fine.
>>
>> When I add a new user I first add them to the File Server and then I
>> do it on the other machines. I get a warning that the home directory
>> has already been created but that is fine. The ID's are consistent
>> across machines.
>>
>> After an account is created (kehuang in this case) all is fine on the Head Node:
>>
>> drwxr-x---   4 kehuang    omg           153 Jan 23 18:54 kehuang
>> drwxr-x---  32 zwenzhou   omg          4096 Jan 23 18:56 zwenzhou
>> drwxr-x---  35 mjohnson   forestry     4096 Jan 24 00:26 mjohnson
>> drwxr-x--- 118 cousins    cousins      8192 Jan 24 10:43 cousins
>>
>>
>> But on Backup1 and GPU I get "nobody" for the new user:
>>
>> drwxr-x---   4 nobody     omg           153 Jan 23 15:54 kehuang
>> drwxr-x---  32 zwenzhou   omg          4096 Jan 23 15:56 zwenzhou
>> drwxr-x---  35 mjohnson   forestry     4096 Jan 23 21:26 mjohnson
>> drwxr-x--- 118 cousins    cousins      8192 Jan 24 07:43 cousins
>>
>> The GID maps fine though, probably because it is not a new group.
>>
>> I have tried restarting rpcidmapd on the nodes but it doesn't help.
>> The only thing I have found that works is a reboot.
>>
>> Has anyone run across this before? Anyone know a solution?  It doesn't
>> seem to be a idmapd.conf issue since it works fine until a new user is
>> added.
>>
>> One odd thing though is that the id maps to 99:nobody instead of
>> 65534:nfsnobody.
>>
>> Here is what idmapd.conf looks like on all machines:
>>
>> [General]
>> Verbosity = 0
>> Domain = localdomain
>>
>> [Mapping]
>> Nobody-User = nfsnobody
>> Nobody-Group = nfsnobody
>>
>> [Translation]
>> Method = nsswitch
>>
>>
>> Thanks for your help.
>>
>> Steve
>
> It's likely that your client nodes tried to do a NFSv4 id to uid
> translation prior to being aware of that account, so you likely have an
> negative lookup in the cache.
>
> The default timeout for client ID mapping is 10 mins and is settable by
> module parm. If you wait that long after you see the entry, does it
> eventually time out?
>
> It's also possible to force the cache to be cleared by having root run
> nfsidmap -c (see the manpage for details).


Hi Jeff,

Thanks. That's the kind of thing I was hoping for but it persists
until a reboot.

I just tried nfsidmap -c on one of the client machines and it didn't
seem to help at first but then after a while it did.

Great! Thanks very much. It would be best if it would actually timeout
so this wasn't needed but I'm glad to have a way to repair it when
needed.

Steve



>
> --
> Jeff Layton <jlayton@redhat.com>
