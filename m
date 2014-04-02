Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:56067 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932747AbaDBVsZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Apr 2014 17:48:25 -0400
Received: by mail-ie0-f173.google.com with SMTP id rl12so955852iec.18
        for <linux-nfs@vger.kernel.org>; Wed, 02 Apr 2014 14:48:25 -0700 (PDT)
Content-Type: text/plain; charset=iso-8859-1
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Quick way to check if file is on nfs?
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <533C7E2F.7060201@candelatech.com>
Date: Wed, 2 Apr 2014 17:48:21 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <A3711EB3-8384-4BD4-944B-9C3260F566A1@primarydata.com>
References: <533C7E2F.7060201@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 2, 2014, at 17:16, Ben Greear <greearb@candelatech.com> wrote:

> Is there an efficient way to tell if a file we just opened is on
> NFS vs local disk?  We have reports of a bug where our program thinks
> it has mounted nfs and starts writing to the nfs file system, but later
> somehow local disk gets filled up instead.  I'd like to detect when
> we are no longer writing to the mount point so I can stop the test,
> gather logs, etc.
> 
> Thanks,
> Ben

Call fstatfs() on the file descriptor and look at the returned f_type?

Cheers
  Trond

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

