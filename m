From: Sid Moore <learnmost@gmail.com>
Subject: Re: Report bug: space not released when file deleted.
Date: Tue, 24 May 2011 09:40:01 +0800
Message-ID: <BANLkTinoByoB4+yrY5oiptB2-ijvwoXgVQ@mail.gmail.com>
References: <BANLkTikCdr6P-WFBdshPwiBQ5_LK-qobLQ@mail.gmail.com>
	<20110523073027.271cb61f@corrin.poochiereds.net>
	<20110523140219.GA25334@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:42731 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758070Ab1EXBkC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 21:40:02 -0400
Received: by gwaa18 with SMTP id a18so2378459gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 May 2011 18:40:01 -0700 (PDT)
In-Reply-To: <20110523140219.GA25334@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks!  I will check this patch.

On Mon, May 23, 2011 at 10:02 PM, J. Bruce Fields <bfields@fieldses.org=
> wrote:
> On Mon, May 23, 2011 at 07:30:27AM -0400, Jeff Layton wrote:
>> On Mon, 23 May 2011 13:42:41 +0800
>> Sid Moore <learnmost@gmail.com> wrote:
>>
>> > Hi,
>> >
>> > On Linux NFS, I found a file deleted but its space not released in
>> > NFSv3. It is on 2.6.32.
>> >
>> > The steps for reproducing are listed below.
>> > 1) create a ext3 filesystem on a device, mount it to local dir
>> > /exports/fs1_ext3/, export /exports/fs1_ext3/ with no_subtree_chec=
k to
>> > a NFS client. this client mount this exported dir with infinite
>> > retrans.
>> > 2) on the ext3 fs, create a large regular file =A0(say: 600MB)
>> > 3) on NFS client, starts several processes who reading this file i=
n 2)
>> > in parallel
>> > 4) during step 3), kill all nfsd threads, umount this ext3 fs; the=
n
>> > mount this ext3 to /exports/fs1_ext3; start 8 nfsd threads.
>> > 5) after processes finished reading, delete this file. then, I fou=
nd
>> > the space occupied but this file not released.
>> >
>> > during step 4), I think an anonymous dentry of this file was creat=
ed
>> > after fh_verify(). in step 5), a named dentry of this file also
>> > created. So, there are two dentry on this inode. but when deleting=
,
>> > only the named dentry deleted. only restart this ext3 fs or dcache
>> > shrinked, the anonymous dentry will not be released and it referen=
ced
>> > the inode of this file. so its space not freed.
>> >
>> > is my analysis correct? =A0anyone has encountered this issue befor=
e? or,
>> > this issue was fixed by someone? Thanks.
>> >
>>
>> You may want to test a more recent kernel on the server before you d=
ig
>> in too deeply. I know that Bruce has fixed a number of these sorts o=
f
>> problems recently.
>
> Yes, this should be fixed by d891eedbc3b1b0fade8a9ce60cc0eba1cccb59e5=
,
> in 2.6.38.
>
> --b.
>
