Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f178.google.com ([209.85.212.178]:49429 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172Ab2EVSHL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 14:07:11 -0400
Received: by wibhn6 with SMTP id hn6so3812524wib.1
        for <linux-nfs@vger.kernel.org>; Tue, 22 May 2012 11:07:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1337708765.4269.26.camel@lade.trondhjem.org>
References: <1337688569-1515-1-git-send-email-andros@netapp.com>
	<1337688569-1515-5-git-send-email-andros@netapp.com>
	<1337703865.4269.21.camel@lade.trondhjem.org>
	<4D70BD9B-4F81-4E57-8689-DCE6F8B1A1C2@netapp.com>
	<1337708765.4269.26.camel@lade.trondhjem.org>
Date: Tue, 22 May 2012 14:07:10 -0400
Message-ID: <CAHVgHyV_mm6234=1CmS8+1Lcp0A1yGBRmhLX31m1cjGkFZJLcw@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFSv4.1 do not release page on commit mismatch
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2012 at 1:46 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Tue, 2012-05-22 at 16:30 +0000, Adamson, Andy wrote:
>> On May 22, 2012, at 12:24 PM, Myklebust, Trond wrote:
>>
>> > On Tue, 2012-05-22 at 08:09 -0400, andros@netapp.com wrote:
>> >> From: Andy Adamson <andros@netapp.com>
>> >>
>> >> Signed-off-by: Andy Adamson <andros@netapp.com>
>> >> ---
>> >> fs/nfs/write.c |    2 ++
>> >> 1 files changed, 2 insertions(+), 0 deletions(-)
>> >>
>> >> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> >> index e6fe3d6..c7295de 100644
>> >> --- a/fs/nfs/write.c
>> >> +++ b/fs/nfs/write.c
>> >> @@ -1555,6 +1555,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
>> >>            /* We have a mismatch. Write the page again */
>> >>            dprintk(" mismatch\n");
>> >>            nfs_mark_request_dirty(req);
>> >> +          nfs_unlock_request(req);
>> >> +          continue;
>> >>    next:
>> >>            nfs_unlock_and_release_request(req);
>> >>    }
>> >
>> > What is this patch trying to fix? As far as I can see it will lead to a
>> > reference leak.
>>
>> The release of the page drops the refcount to zero. Since it is a mismatch, we want to continue to use the page, so nfs_page_find_request_locked is called we get the WARNING in kref_get, and an Oops in various places in pnfs_update_layout.
>>
>> Here is the output of added printk's.
>>
>> -->Andy
>>
>> May 21 18:25:33 fedora-64-2 kernel: [  152.988921] NFS:       commit (0:35/2 4096@184320)
>> May 21 18:25:33 fedora-64-2 kernel: [  152.988923]  mismatch req ffff880042dbb800
>> May 21 18:25:33 fedora-64-2 kernel: [  152.988927] nfs_release_request WB req ffff880042dbb800 wb_kref 1
>> May 21 18:25:33 fedora-64-2 kernel: [  152.988932] put_lseg: lseg ffff880042d95380 ref 4 valid 0
>> May 21 18:25:33 fedora-64-2 kernel: [  152.988945] nfs_page_find_request_locked req ffff88003e033800
>> May 21 18:25:33 fedora-64-2 kernel: [  152.988949] nfs_page_find_request_locked WB req ffff88003e033800 wb_kref 0
>> May 21 18:25:33 fedora-64-2 kernel: [  152.988953] ------------[ cut here ]------------
>> May 21 18:25:33 fedora-64-2 kernel: [  152.989082] WARNING: at include/linux/kref.h:41 kref_get+0x20/0x2c [nfs]()
>
> Are these commit-to-ds requests?

Yes

-->Andy

> As far as I can see, there is a bug in
> transfer_commit_list() in that it locks the requests, but does not
> reference them.
>
> Fred?
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
