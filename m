Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f180.google.com ([209.85.220.180]:39348 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610AbbB0UiY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2015 15:38:24 -0500
Received: by mail-vc0-f180.google.com with SMTP id le20so459698vcb.11
        for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2015 12:38:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtRyAWCTKajL_h3Er187Mwey25HxfXe6W0XM2MH-3-Q=5A@mail.gmail.com>
References: <1425009509-3809-1-git-send-email-trond.myklebust@primarydata.com>
	<47B66753-080A-4B8F-8F31-ACE76447EF55@oracle.com>
	<CAHQdGtRyAWCTKajL_h3Er187Mwey25HxfXe6W0XM2MH-3-Q=5A@mail.gmail.com>
Date: Fri, 27 Feb 2015 15:38:24 -0500
Message-ID: <CAHQdGtS03kK0iVuPh5b_HbNP4GPnznCM8LwyTKrcB8c-4xKarg@mail.gmail.com>
Subject: Re: [PATCH v2 1/8] NFS: Add a helper to set attribute barriers
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 27, 2015 at 3:25 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Fri, Feb 27, 2015 at 3:16 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> A new failure occurred with Solaris 11 server, not with the other two.
>> I’ve never seen this one before. I will see if it’s reproducible.
>>
>> generic/207 1s ... [failed, exit status 1] - output mismatch (see /home/cel/src/xfstests/results//generic/207.out.bad)
>>     --- tests/generic/207.out   2014-02-13 15:40:45.204103195 -0500
>>     +++ /home/cel/src/xfstests/results//generic/207.out.bad     2015-02-27 11:55:47.943262225 -0500
>>     @@ -1,2 +1,2 @@
>>      QA output created by 207
>>     -4000 iterations of racing extensions and collection passed
>>     +write of 4096 bytes @16379904 finished, expected filesize at least 16384000, but got 16379904
>
> Huh. I'll look into this.

I suspect this is because we're performing the comparison against
inode->i_size outside the inode->i_lock spinlock in
nfs_writeback_check_extend(). That means that another earlier write
which also extends the file could in theory race, set a higher value
for the barrier, and "win".

In order to fix this, we want to perform the above test and then
update inode->i_size without dropping the spinlock.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
