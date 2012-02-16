Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37215 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753169Ab2BPVPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 16:15:38 -0500
Received: by wgbdt10 with SMTP id dt10so2179739wgb.1
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 13:15:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329425444.19793.16.camel@lade.trondhjem.org>
References: <1329346205-2316-1-git-send-email-andros@netapp.com>
	<1329346205-2316-2-git-send-email-andros@netapp.com>
	<1329425444.19793.16.camel@lade.trondhjem.org>
Date: Thu, 16 Feb 2012 16:15:37 -0500
Message-ID: <CAHVgHyVbVRsxcrJ=+b2WdyL5FnJ5UouyUGj3vvaif9jDN-UNag@mail.gmail.com>
Subject: Re: [PATCH Version 2 nfs-for-next 1/1] NFSv4.1 add a session
 statistics file to /proc/fs/nfsfs
From: Andy Adamson <androsadamson@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2012 at 3:50 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Wed, 2012-02-15 at 17:50 -0500, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> Session statistics are needed for performance characterisation and debugging
>> recovery and migration.
>>
>> Only gather forechannel statistics as the backchannel has one session slot.
>>
>
> Could this be done better using tracepoints? I'm not sure that I see how
> a typical system admin would use this kind of file, so it looks more
> like a debugging aid.

It is similar to the mountstats xprt stanza with waitq lengths, but I
see your point.  I'll look into a tracepoint version.

Any suggestions of other session info to gather?

-->Andy
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
