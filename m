Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f48.google.com ([209.85.220.48]:55662 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbaCGNNE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Mar 2014 08:13:04 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz1so4129217pad.21
        for <linux-nfs@vger.kernel.org>; Fri, 07 Mar 2014 05:13:04 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] fix intr/nointr to match kernel behavior (ignored)
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140307185937.5852666b@notabene.brown>
Date: Fri, 7 Mar 2014 08:13:00 -0500
Cc: Jim Rees <rees@umich.edu>, Dickson Steve <steved@redhat.com>,
        linux-nfs@vger.kernel.org
Message-Id: <D65A0AA5-ADF9-43AA-871F-69533C8F2DD7@primarydata.com>
References: <1394143352-26095-1-git-send-email-rees@umich.edu> <20140307185937.5852666b@notabene.brown>
To: Brown Neil <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 7, 2014, at 2:59, NeilBrown <neilb@suse.de> wrote:

> On Thu,  6 Mar 2014 17:02:32 -0500 Jim Rees <rees@umich.edu> wrote:
> 
>> Signed-off-by: Jim Rees <rees@umich.edu>
>> ---
>> utils/mount/nfs.man | 53 ++++++-----------------------------------------------
>> 1 file changed, 6 insertions(+), 47 deletions(-)
>> 
>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>> index ef09a31..2ab369c 100644
>> --- a/utils/mount/nfs.man
>> +++ b/utils/mount/nfs.man
>> @@ -125,6 +125,12 @@ option may mitigate some of the risks of using the
>> .B soft
>> option.
>> .TP 1.5i
>> +.BR intr " / " nointr
>> +This option is provided for backward compatibility.
>> +It is ignored after kernel 2.6.25.
>> +System calls return EINTR if an in-progress NFS operation is interrupted by
>> +a signal.
> 
> That isn't correct.
> "A process that is waiting for a reply for an NFS server can be killed
> by any signal which would normally kill the process.  If a signal would not
> normally kill the process (i.e. it is caught or ignored) then that signal
> will not abort and NFS request".
> 
> This is really a fairly horrible semantic.  It makes perfect sense from an
> internal implementation perspective and provides good backwards compatibility
> and cross-compatibility with other filesystems (where 'read' and 'write'
> never ever return EINTR), but it is very hard to document clearly.
> 
Isn’t the documentation in the signal(7) manpage sufficient? We could simply refer to that…

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

