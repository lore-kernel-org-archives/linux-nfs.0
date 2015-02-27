Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mxout1.mail.janestreet.com ([38.105.200.112]:34778 "EHLO
	mxout1.mail.janestreet.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753261AbbB0UOK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Feb 2015 15:14:10 -0500
Received: from tot-qpr-mailcore1.delacy.com ([172.27.56.68] helo=tot-qpr-mailcore1)
	by mxout1.mail.janestreet.com with smtp (Exim 4.82)
	(envelope-from <cperl@janestreet.com>)
	id 1YRRIX-0002qR-Ep
	for linux-nfs@vger.kernel.org; Fri, 27 Feb 2015 15:14:09 -0500
Received: from mail-yk0-f176.google.com ([209.85.160.176])
	by mxgoog1.mail.janestreet.com with esmtps (UNKNOWN:AES128-GCM-SHA256:128)
	(Exim 4.72)
	(envelope-from <cperl@janestreet.com>)
	id 1YRRIX-000517-9v
	for linux-nfs@vger.kernel.org; Fri, 27 Feb 2015 15:14:09 -0500
Received: by ykq19 with SMTP id 19so8216924ykq.9
        for <linux-nfs@vger.kernel.org>; Fri, 27 Feb 2015 12:14:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHHaOubVomDJ5uePb7DFGizZ0TBsyC-tJN5p6-RWOYKQC2oxvA@mail.gmail.com>
References: <CAAih9mgvxu+L2Y7yxbHCOKX39Cm5U6ZCd5-HkJUUMFTL9moSwA@mail.gmail.com>
 <CAHQdGtSvwbVeTD-ALEU=6MJYts=61o1TaUVN6Vky1nwrKPTJXQ@mail.gmail.com>
 <CAAih9mhNUK6-eeAxM8VcdTCx3b59ztAVHSd37HiYaJr-AbX_1w@mail.gmail.com>
 <CAHQdGtS1b7Yjs4QozG1R+wxhxvRbCA85ZNCNQG6-ccyDeg+_gA@mail.gmail.com>
 <CAAih9mg1CkcTYGGZRwg8YPzEkZeqB686s+difvoBHFKfC=VD=g@mail.gmail.com>
 <CAHQdGtTUcP9b7YBk1Wu_HTO9z=TQF=Dfixig3_Cww=VSaxqGDw@mail.gmail.com>
 <CAAih9mijyXYSQ6=ckg3J-Kje1fhdjQFVTyB6KvoKYfFbW9cfLQ@mail.gmail.com>
 <CAHQdGtR7pZz2OsGbMi0cM9MoqmEFWtaStgWwBfSoSebkYmTcMg@mail.gmail.com>
 <CAAih9miZ8SA2EMz6OkAuLhDox8MLEKpXB7f75LJx5FO9zgm8Rg@mail.gmail.com> <CAHHaOubVomDJ5uePb7DFGizZ0TBsyC-tJN5p6-RWOYKQC2oxvA@mail.gmail.com>
From: Chris Perl <cperl@janestreet.com>
Date: Fri, 27 Feb 2015 15:13:48 -0500
Message-ID: <CAAih9mjHzZeS17rKSG06pzCh7zCPFd=nG1=hMSU+T+GW5btPEA@mail.gmail.com>
Subject: Re: File Read Returns Non-existent Null Bytes
To: David Brodbeck <brodbd@uw.edu>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I *think* in the situation where the file is being appended to, you're not
> likely to see anything but nulls.

Agreed.

> I'm not an expert but I think this occurs
> when the read happens between the file size being extended and the new data
> being written, effectively making a 'hole' at the end of the file.

As said in other replies, its because the size is updated causing too
much data to be read out of the page cache, effectively appending
NULLs to the data.

> When you're reading a file that's been concurrently modified, you can get
> corruption (a mix of new and old data) on pretty much any filesystem that
> doesn't enforce mandatory locks.  It's just much less likely on a local
> filesystem because the window is shorter and more operations are atomic.

If you're talking about a local filesystem and you have one process
appending data (with O_APPEND) and another reading, I don't believe
you'll see the same sort of issue (but, I could be wrong).
