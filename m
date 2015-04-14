Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:36242 "EHLO
	mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933056AbbDNRZy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Apr 2015 13:25:54 -0400
Received: by oift201 with SMTP id t201so7162963oif.3
        for <linux-nfs@vger.kernel.org>; Tue, 14 Apr 2015 10:25:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.OSX.2.19.9992.1504130858420.4187@planck.local>
References: <CALr0QzFXae_Hjki15o2gQoNDua0xWZjb3nDexBy-OFezK5-gXQ@mail.gmail.com>
	<alpine.OSX.2.19.9992.1504130858420.4187@planck.local>
Date: Tue, 14 Apr 2015 19:25:53 +0200
Message-ID: <CALr0QzGjDJa5=DA-aoxhv9r+Y1AROrUoVCUhfCp=JXZoRMZn+g@mail.gmail.com>
Subject: Re: Split NFS4 share on multiple servers
From: Prunk Dump <prunkdump@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2015-04-13 15:37 GMT+02:00 Benjamin Coddington <bcodding@redhat.com>:
> Hi Baptiste,
>
> On Sat, 11 Apr 2015, Prunk Dump wrote:
>
>> Hello NFS team,
>>
>> On my network I share my users' home directories from a kerberized NFS4 server.
>>
>> I would like to split this shared filesystem tree on 3 servers to
>> reduce server loading and increase storage capacity. I don't want file
>> replication, just distribution.
>>
>> On this link :
>>
>> http://www.ibm.com/developerworks/library/l-generic-nfs-mount/
>>
>> I can read that "NFS version 4 provides a pseudo-tree mechanism that
>> enables a single mount of all NFSv4 exported entries"
>>
>> I can't find documentation of this feature. Is it works on multiple
>> servers ? Is this possible to mount multiple NFS4 shares on a same
>> mount point without using a special file system like Unionfs or
>> Glusterfs ?
>
> I believe they are talking about NFSv4 referrals, and it is possible
> provided your server supports the fs_locations attribute.
>
>> What is the preferred way of network administrators to distribute
>> their users' home directories through NFS4 ?
>
> One method I've used for an installation with < 100k users was based on
> a simple automount map and using symlinks to hash out users' home
> directories on a "lookup" filesystem.
>
> There's a "lookup" filesystem automounted on every client here:
>
> /users
>
> with directories like /users/b/c/ and /users/f/o.  Each directory contains
> symlinks to users' real home directory location, for example:
>
> /users/b/c/bcodding -> /nfs/04/users/b/c/bcodding
> /users/f/o/foo      -> /nfs/f2/users/f/o/foo
>
> Users' pwnam home directories are of the predictable form:
>
> /users/b/c/bcodding
> /users/f/o/foo
>
> The main file servers themselves are automounted on each client at
> /nfs/<servername> as you can see in the symlink targets above.  Predictable
> naming conventions allow you to use autofs wildcarding for server name
> matches, so you don't need to update the maps to scale.
>
> The lookup filesystem becomes a single point of failure, but that can be
> mitigated in a few ways that are simplified by the fact that this data is
> almost always RO and is very small.
>
> A migration of a users' home dir can become an issue if you don't have full
> control of the clients, so you can avoid this by starting with a very wide
> distribution of file servers and growing the filesystems over time.  In this
> setup, there were only a few clients that could write, so migrations were
> eased by only migrating users if they didn't have open files on those
> client.
>
> If you're using shared storage, even better.  You can match server names to
> block devices and script-mount them in the file servers so that deploying a
> new fileserver can be done by allocating the block device and cloning the
> fileserver image.
>
> Shared storage also provides an HA or scriptable availability solution by
> allowing you to recover a file server from a known good image, or migrate
> the underlying block device to a known good server.
>
> HTH,
> Ben
>
>>
>> Thanks,
>> Baptiste.
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>


Thank you Benjamin ! You help me a lot !

NFSv4 referrals is exactly what I search for. I need to check if it is
well supported on my Debian Wheezy servers and clients.

I have approximately 1100 users and 350 computers so I need to have
the possibility to move the home folders easily between my servers.

If I can't get the NFS referrals working I will try with you second solution.

Thank you again !

Baptiste.
