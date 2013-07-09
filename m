Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f175.google.com ([74.125.82.175]:59943 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768Ab3GIH7N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jul 2013 03:59:13 -0400
Received: by mail-we0-f175.google.com with SMTP id t59so4494691wes.34
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jul 2013 00:59:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130708143957.2ebc75e3@tlielax.poochiereds.net>
References: <CAF38w7Xx0_TqZem6cen+EJKpUrziGT_dAVcjG7oFFwM+ANm5mA@mail.gmail.com>
	<CAF38w7Xf87k=GfM38XcO+ag+Na=f=Mg1KDn0jv2Y8Yp6Q_5a=g@mail.gmail.com>
	<20130708143957.2ebc75e3@tlielax.poochiereds.net>
Date: Tue, 9 Jul 2013 09:59:12 +0200
Message-ID: <CAF38w7WUy6ENvppTW5CWbQMRwheTnwQj1e1QQabWUBU13iffNA@mail.gmail.com>
Subject: Re: Problem with sharing mounted iso
From: Johan GUILBAUD <guilbaud.johan@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for this information Jeff, but i'll have more than one hundred
iso mounted... so adding each in exports... ^^

after tests, it works with Solaris 8 (sunos 5.8) but not with Solaris
10 (sunos 5.10), i don't understand why... i use same command to mount
my share...

 mount [-F nfs] myisoserver:/pub/ /isos

any idea ?

2013/7/8 Jeff Layton <jlayton@redhat.com>:
> On Mon, 8 Jul 2013 14:47:00 +0200
> Johan GUILBAUD <guilbaud.johan@gmail.com> wrote:
>
>> Hello !
>>
>> I have a problem to access a mounted ISO through NFS protocol
>>
>> i have a server (RHEL6) on which are mounted ISOs
>> i have a lot of client accessing files into ISO via the NFS share
>>
>> My problem is clients (RHEL5 & 6, Solaris 8 & 10) don't see content of
>> ISO folder
>>
>> In example :
>>
>> on NFS server i have a folder /pub/ where the ISO are mounted (ie :
>> with the iso mybeautifuliso.iso on the mount point
>> "/pub/mybeautifuliso/") there are also, for test, text files in /pub/
>> NFS shares content of /pub
>>
>>
>> Client see tests text files, and folder "mybeautifuliso" but this one
>> is empty...
>>
>>
>> thanks for help
>>
>
> Exports don't cross mountpoints by default, so if you exported "/pub"
> no filesystem mounted under it will be automatically exported. The best
> solution is to explicitly export those filesystems as well -- i.e. add
> an export of "/pub/mybeautifuliso". Then, when clients wander into
> those directories they should see the contents.
>
> --
> Jeff Layton <jlayton@redhat.com>



-- 
GUILBAUD Johan
