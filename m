Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:52304 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab2DZRKv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Apr 2012 13:10:51 -0400
MIME-Version: 1.0
In-Reply-To: <CAH2r5muXk+frkFz9X523Ny=RMwJGeqOPH75G1ToNa5QoMo5SkQ@mail.gmail.com>
References: <20120419140558.17272.74360.stgit@warthog.procyon.org.uk>
	<CAH2r5ms4WQV3DnTvqNN=2N71Cj8UHwj8Z6+RHXgrAOv6mSoyQg@mail.gmail.com>
	<20656.1335450358@redhat.com>
	<CAH2r5mv1Lijdwk5zsQwYJr4Etb6fhrRyNXm-iFCQX+HecboGrQ@mail.gmail.com>
	<1335453958.9701.10.camel@lade.trondhjem.org>
	<CAH2r5mt5af-_hxBRKK72iD5Gr99bo91ec78Rov8EGVEx8=21mA@mail.gmail.com>
	<1335459642.9701.27.camel@lade.trondhjem.org>
	<CAH2r5mvmCfLrxRHje6Wx5X84zxPEHwRMUJGsjvWBujMu7w841w@mail.gmail.com>
	<1335460011.9701.30.camel@lade.trondhjem.org>
	<CAH2r5muXk+frkFz9X523Ny=RMwJGeqOPH75G1ToNa5QoMo5SkQ@mail.gmail.com>
Date: Thu, 26 Apr 2012 12:10:50 -0500
Message-ID: <CAH2r5mu6i6aKLqt2EagBECSEU7jxsy-muAwcXThKJ51cd+CHpQ@mail.gmail.com>
Subject: Re: [PATCH 0/6] Extended file stat system call
From: Steve French <smfrench@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: David Howells <dhowells@redhat.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-cifs@vger.kernel.org" <linux-cifs@vger.kernel.org>,
        "samba-technical@lists.samba.org" <samba-technical@lists.samba.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "wine-devel@winehq.org" <wine-devel@winehq.org>,
        "kfm-devel@kde.org" <kfm-devel@kde.org>,
        "nautilus-list@gnome.org" <nautilus-list@gnome.org>,
        "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
        "libc-alpha@sourceware.org" <libc-alpha@sourceware.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 26, 2012 at 12:09 PM, Steve French <smfrench@gmail.com> wrote:
> On Thu, Apr 26, 2012 at 12:06 PM, Myklebust, Trond
> <Trond.Myklebust@netapp.com> wrote:
>> On Thu, 2012-04-26 at 12:03 -0500, Steve French wrote:
>>> On Thu, Apr 26, 2012 at 12:00 PM, Myklebust, Trond
>>> <Trond.Myklebust@netapp.com> wrote:
>>> > On Thu, 2012-04-26 at 11:56 -0500, Steve French wrote:
>>> >> On Thu, Apr 26, 2012 at 10:25 AM, Myklebust, Trond
>>> >> <Trond.Myklebust@netapp.com> wrote:
>>> >> > On Thu, 2012-04-26 at 09:54 -0500, Steve French wrote:
>>> >> >> On Thu, Apr 26, 2012 at 9:25 AM, David Howells <dhowells@redhat.com> wrote:
>>> >> >> > Steve French <smfrench@gmail.com> wrote:
>>> >> >> >
>>> >> >> >> Would it be better to make the stable vs volatile inode number an attribute
>>> >> >> >> of the volume  or something returned by the proposed xstat?
>>> >> >> >
>>> >> >> > I'm not sure what you mean by a stable vs a volatile inode number.
>>> >> >>
>>> >> >> Both NFS and CIFS (and SMB2) can return inode numbers or equivalent
>>> >> >> unique identifier, but in the case of CIFS some old servers don't support the
>>> >> >> calls which return inode numbers (or don't return them for all file system
>>> >> >> types, Windows FAT?) so in these cases cifs has to create inode
>>> >> >> numbers on the fly
>>> >> >> on the client.   inode numbers created on the client are not "stable" they
>>> >> >> can change on unmount/remount (which can cause problems for backup
>>> >> >> applications).
>>> >> >>
>>> >> >> Similarly NFSv4 does not require that servers always return stable inode numbers
>>> >> >> (that will never change) and introduced a concept of "volatile file handle."
>>> >> >> We have run into this in two cases (there are probably more) -
>>> >> >> Specialized NFS servers
>>> >> >> for HPC which deal with lots of transient inodes, and second those for servers
>>> >> >> which base there inode number on path (Windows NFS?).  See
>>> >> >> http://docs.oracle.com/cd/E19082-01/819-1634/rfsrefer-137/index.html
>>> >> >> or the NFSv4 RFC.
>>> >> >>
>>> >> >> Basically the question is whether it is worth reporting a flag on the
>>> >> >> call which returns
>>> >> >> the inode number to indicate that the inode number is "stable" (would not change
>>> >> >> on reboot or reconnection) or "volatile."    Since the majority of NFS
>>> >> >> and SMB2 servers
>>> >> >> can return stable inode numbers, I don't feel strongly about the need
>>> >> >> for an indicator
>>> >> >> of "stable" vs. "volatile" but I mention it because backup and
>>> >> >> migration applications
>>> >> >> mention this (if inode numbers are volatile, they may have to check
>>> >> >> for hardlinks differently
>>> >> >> for example)
>>> >> >
>>> >> > I don't understand. If the filesystem doesn't support real inode
>>> >> > numbers, then why report them at all? What use would an application have
>>> >> > for an inode number that can't be used to identify hard linked files?
>>> >>
>>> >> Well ... you have to have an inode number on the Linux client side even if
>>> >> the server doesn't report them (or has a bug and reports duplicates).
>>> >> If you can't tell hardlinked files apart fix the server (but in the
>>> >> cases where the file systems has this problem the server doesn't usually
>>> >> support hardlinks either).
>>> >>
>>> >> If the server's file system internal structures don't support real inode
>>> >> numbers (such as FAT or a ramdisk) then it either has to make them
>>> >> up based on something like path name or some other attribute of the
>>> >> file on disk.
>>> >>
>>> >> Servers like NetApp is where this gets interesting - for cifs e.g. level 1009
>>> >> query file info is used to query_file_internal_info (the inode number) but
>>> >> what if the server can not report inode numbers (due to a bug) in
>>> >> all cases.
>>> >
>>> > Right, but none of this explains why we need to report these bogus inode
>>> > numbers to the application in the xstat() reply.
>>>
>>> the question is whether the application (backup) would need to know
>>> that the inode numbers are bogus and from my conversations with
>>> guys writing backup software it seems that such data is useful to them.
>>
>> You are still not explaining why they need to know the values at all? If
>> the values are bogus, then don't return them, and don't set the flag
>> that says they are being returned.
>
> I don't know, but assumed it was because it was an easy way
> to index them since the inode numbers even if they "change"
> on remount, are still unique.

if the call allows the inode number not to be returned, that
is probably ok (they can always use the posix stat to get
the client generated one)



-- 
Thanks,

Steve
