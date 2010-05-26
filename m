Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:52498 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269Ab0EZMDQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 May 2010 08:03:16 -0400
Received: by gyg13 with SMTP id 13so2773001gyg.19
        for <linux-nfs@vger.kernel.org>; Wed, 26 May 2010 05:03:15 -0700 (PDT)
In-Reply-To: <20100524081155.03046681@notabene.brown>
References: <AANLkTikZfdnCMm0TkEaVnN2kqVzMZ7CYmbe1YengmRMY@mail.gmail.com>
	<AANLkTilYaqsm-Yp-LKaB2H0lTxm6_YjKwEJ2AVEn4wJt@mail.gmail.com>
	<20100524081155.03046681@notabene.brown>
Date: Wed, 26 May 2010 22:03:14 +1000
Message-ID: <AANLkTikl4BoDojxAYe-knRhOvST7mgLfUOkaIsn1L2Kf@mail.gmail.com>
Subject: Re: NFS cache
From: hce <webmail.hce@gmail.com>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 24, 2010 at 8:11 AM, Neil Brown <neilb@suse.de> wrote:
> On Mon, 17 May 2010 09:54:12 +1000
> hce <webmail.hce@gmail.com> wrote:
>
>> On Sun, May 16, 2010 at 6:26 PM, hce <webmail.hce@gmail.com> wrote:
>> > Hi,
>> >
>> > I posted following message on list, but did not see it on list, sorry
>> > if it is duplicated.
>> >
>> > I have an application to use NFS over FUSE, if I keep typing "ls" in
>> > the same directory, the client NFS only sent GETATT, no more READDIR,
>> > all directory contents displayed on screen came from NFS cache. That
>> > caused many problems and I'd like to disable NFS client cache. But it
>> > did not work when I add "-o noac" option to mount.
>>
>> I've just realised that the noac is only for NFS attribute cache, so
>> add "-o noac" only generates more getatt for up paths, the "readdir"
>> was still not called if I keep typing "ls" in the same directory.
>>
>> Does NFS has another cache for directory structure as well? It seems
>> it displayed directory contents on the screen from cache as it did not
>> call readdir to FUSe.
>
> (almost) all linux filesystems use the 'page cache' for storing parts or all
> of files and directories.
> Linux/NFS uses the page cache to store the contents of a directory.  It will
> normally only refresh the cached directory when the 'mtime' or the 'ctime' of
> the directory (as reported by GETATTR) changes.

I guess you were talking about NFS client uses the page cache to store
contents of a directory. Is any way I can disable NFS to use page
cache to store contents of a directory? I have an application which
has its own cache, There are various problems as the NFS / FUSE does
not work well together expecially it took excessive large time when to
list large number files (100 K).

Thanks NeilBrown.
