Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f172.google.com ([209.85.128.172]:46629 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764497Ab3DDS2q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 14:28:46 -0400
Received: by mail-ve0-f172.google.com with SMTP id oz10so2904947veb.17
        for <linux-nfs@vger.kernel.org>; Thu, 04 Apr 2013 11:28:45 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20130404163525.GA8953@umich.edu>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
	<05CFAB4A-8329-4657-B250-1A36105086AA@oracle.com>
	<20130404160142.GA8739@umich.edu>
	<1365092115.10726.25.camel@leira.trondhjem.org>
	<20130404163525.GA8953@umich.edu>
Date: Thu, 4 Apr 2013 20:28:45 +0200
Message-ID: <CAGue13pQ_QbwHoPpLv5zRoESNoVf_tRb7cfptLdytjk7mzAJmw@mail.gmail.com>
Subject: Re: readdir vs. getattr
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Jim Rees <rees@umich.edu>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, by tweaking the values of acregmin and acregmax I got the expected
behaviour.

What about this double GETATTR on directory itself?

Tigran.

On Thu, Apr 4, 2013 at 6:35 PM, Jim Rees <rees@umich.edu> wrote:
> Myklebust, Trond wrote:
>
>   On Thu, 2013-04-04 at 12:01 -0400, Jim Rees wrote:
>   > Chuck Lever wrote:
>   >
>   >   > So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.
>   >
>   >   Default these days is ls --color
>   >
>   > No it's not, at least not on linux. From the man page:
>   >
>   > "Using color to distinguish file types is disabled both by default and with
>   > --color=never."
>
>   Yes, but a number of Linux distros override that in /etc/profile. For
>   instance all Red Hat/Fedora distros have aliases for ls that map them to
>   'ls --color=auto'
>
> I was actually just trying to figure out whether the application (ls) was
> doing all those file stats, or whether readdir was somehow doing them by
> mistake. Sounds like it's the application.
