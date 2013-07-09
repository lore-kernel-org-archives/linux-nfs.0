Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f170.google.com ([74.125.82.170]:57358 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752846Ab3GINNB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jul 2013 09:13:01 -0400
Received: by mail-we0-f170.google.com with SMTP id w57so4779794wes.29
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jul 2013 06:13:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130709084914.3e7a5372@tlielax.poochiereds.net>
References: <CAF38w7Xx0_TqZem6cen+EJKpUrziGT_dAVcjG7oFFwM+ANm5mA@mail.gmail.com>
	<CAF38w7Xf87k=GfM38XcO+ag+Na=f=Mg1KDn0jv2Y8Yp6Q_5a=g@mail.gmail.com>
	<20130708143957.2ebc75e3@tlielax.poochiereds.net>
	<CAF38w7WUy6ENvppTW5CWbQMRwheTnwQj1e1QQabWUBU13iffNA@mail.gmail.com>
	<1373372050.3641.2.camel@leira.trondhjem.org>
	<20130709084914.3e7a5372@tlielax.poochiereds.net>
Date: Tue, 9 Jul 2013 15:13:00 +0200
Message-ID: <CAF38w7VKK=30WOUOpB5vc_XHpqbz2P6v22SjZ5vxFTnLEEh6QQ@mail.gmail.com>
Subject: Re: Problem with sharing mounted iso
From: Johan GUILBAUD <guilbaud.johan@gmail.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

yes i have tried with nfsv3 when mounting share on my solaris and it works

thanks Trond for the reason...

I guess Solaris 8 don't know nfsv4 and therefore use nfsv3 :)

Thanks all for help !

Have a good day !

NB : sorry for my "bad" english, i'm french.

2013/7/9 Jeff Layton <jlayton@poochiereds.net>:
> On Tue, 9 Jul 2013 12:14:12 +0000
> "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>
>> On Tue, 2013-07-09 at 09:59 +0200, Johan GUILBAUD wrote:
>> > Thanks for this information Jeff, but i'll have more than one hundred
>> > iso mounted... so adding each in exports... ^^
>> >
>> > after tests, it works with Solaris 8 (sunos 5.8) but not with Solaris
>> > 10 (sunos 5.10), i don't understand why... i use same command to mount
>> > my share...
>> >
>> >  mount [-F nfs] myisoserver:/pub/ /isos
>> >
>> > any idea ?
>
> Then the crossmnt mount option is probably what you want (as Bryan
> pointed out earlier).
>
>>
>> AFAICR, the Solaris 10 client does not support crossing mount points.
>> That functionality was added in Solaris 11, as part of the "mirror
>> mount" feature:
>>
>>   http://docs.oracle.com/cd/E23824_01/html/821-1454/ggcvr.html
>>
>> Cheers
>>   Trond
>>
>
> Yes, if it works with Solaris 8, it may be the case that it's using
> NFSv3 and Solaris 10 is using v4 by default. You may want to try
> forcing v3 in the mount options and see if that allows Solaris 10 to
> work.
>
>> > 2013/7/8 Jeff Layton <jlayton@redhat.com>:
>> > > On Mon, 8 Jul 2013 14:47:00 +0200
>> > > Johan GUILBAUD <guilbaud.johan@gmail.com> wrote:
>> > >
>> > >> Hello !
>> > >>
>> > >> I have a problem to access a mounted ISO through NFS protocol
>> > >>
>> > >> i have a server (RHEL6) on which are mounted ISOs
>> > >> i have a lot of client accessing files into ISO via the NFS share
>> > >>
>> > >> My problem is clients (RHEL5 & 6, Solaris 8 & 10) don't see content of
>> > >> ISO folder
>> > >>
>> > >> In example :
>> > >>
>> > >> on NFS server i have a folder /pub/ where the ISO are mounted (ie :
>> > >> with the iso mybeautifuliso.iso on the mount point
>> > >> "/pub/mybeautifuliso/") there are also, for test, text files in /pub/
>> > >> NFS shares content of /pub
>> > >>
>> > >>
>> > >> Client see tests text files, and folder "mybeautifuliso" but this one
>> > >> is empty...
>> > >>
>> > >>
>> > >> thanks for help
>> > >>
>> > >
>> > > Exports don't cross mountpoints by default, so if you exported "/pub"
>> > > no filesystem mounted under it will be automatically exported. The best
>> > > solution is to explicitly export those filesystems as well -- i.e. add
>> > > an export of "/pub/mybeautifuliso". Then, when clients wander into
>> > > those directories they should see the contents.
>> > >
>> > > --
>> > > Jeff Layton <jlayton@redhat.com>
>> >
>> >
>> >
>>
>
>
> --
> Jeff Layton <jlayton@poochiereds.net>



--
GUILBAUD Johan
