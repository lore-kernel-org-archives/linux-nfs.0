Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:45948 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755156Ab2BXVJQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Feb 2012 16:09:16 -0500
Received: by eekc4 with SMTP id c4so1132521eek.19
        for <linux-nfs@vger.kernel.org>; Fri, 24 Feb 2012 13:09:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120223115206.662b325c@redhat.com>
References: <CAMgFM3CXWEXqo+Nr1tt6XS6XrhJVfW9a5Dx=iSACriCOxfXjkw@mail.gmail.com>
 <20120223115206.662b325c@redhat.com>
From: Louie <snikrep@gmail.com>
Date: Fri, 24 Feb 2012 13:08:54 -0800
Message-ID: <CAMgFM3DgWBSUsoSzcvn=2V+eFwj6wUdmb-XQjyyXGfCq9GD-=A@mail.gmail.com>
Subject: Re: v4recovery client id lockup
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for the help, I think I've tracked this down in case anybody
else ever runs into same issue.

We have multiple clients connecting via SSH tunnels, so all NFS
traffic is routed through localhost (127.0.0.1) on these open ports.

The problem appears to be the NFS server only partially recognizing
diff. between these clients through local tunnels. Upon each
alternating connection, the /var/lib/nfs/rpc_pipefs/nfsd4_cb/clntID
directory is replaced with a new one (shows the same IP address of
127.0.0.1, but a new port). The v4recovery client's hash directory is
removed/replaced with the exact same hash. Obviously, when multiple
clients are hitting the box at the same time, this causes a lockup.

I'm guessing there is no solution and our setup just isn't supported.
I'm leaning towards ditching the SSH tunnels and going with
unencrypted traffic for now, as it's not strictly necessary. But if
anybody has a tip on how to fix, would love to hear.

Thanks for the help!

On Thu, Feb 23, 2012 at 8:52 AM, Jeff Layton <jlayton@redhat.com> wrote:
> On Wed, 22 Feb 2012 17:06:49 -0800
> Louie <snikrep@gmail.com> wrote:
>
>> We have a weird, intermittent issue with NFS that I've been trying to
>> track down for the past 6 months. This is on NFS v4, mounted over SSH,
>> with Centos 6.2 as client/server.
>>
>> Periodically, when running a client-side command that reads a large amount of
>> files (e.g. converting 2000 small picture files to another format over
>> NFS), our server will completely lock up for a period of time. ATOP
>> shows 50-90% IO activity on the sda drive (root system, but not the
>> shared NFS area where the files are actually located).
>>
>> I've finally tracked down the activity to the
>> /var/lib/nfs/v4recovery directory. One of the client ID directories
>> gets created/deleted over and over again (same name each time) -
>> enough to completely lock up the system. If I sit on the directory
>> while this is happening and do "ls" commands over and over, you can
>> see it disappear and appear ("ls -i" shows new inode numbers).
>>
>> The strange thing is that this is periodic, and if you simply
>> kill the client process and restart, everything often works smoothly. The
>> actual server IO activity seems to be coming from the journal (what
>> appears in iostat), but it's only writing/rewriting the empty client
>> ID directories (the size of the activity shows 0.0 kb/s).
>>
>> I've searched everywhere for info on this directory and trying to
>> debug this stuff in general and come up empty, sorry if this has been
>> covered before.
>>
>> Appreciate ANY help, this has been driving me completely crazy.
>
> Those directories are for the server to tell what clients are allowed
> to reclaim locks or not. There are some problems that can occur when
> there are server reboots in conjunction with a network partition
> between server and client. See section 8.6.3 in RFC3530 if you're
> interested in the gory details...
>
> In any case, nfsd tracks some info in that directory in order to deal
> with those cases. It's certainly possible there is a bug in that code
> though. I fixed a few subtle bugs in that code recently, with this
> patchset which I've proposed for 3.4:
>
>    [PATCH v6 0/5] nfsd: overhaul the client name tracking code
>
> ...but none that sound similar to what you're seeing. Still, you may
> want to play with that and see whether it helps this case at all. You
> won't need the userspace pieces if you're still using the legacy client
> tracking code.
>
> --
> Jeff Layton <jlayton@redhat.com>
