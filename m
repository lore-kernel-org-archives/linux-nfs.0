Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f172.google.com ([209.85.220.172]:57546 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760675Ab3DDPiC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2013 11:38:02 -0400
Received: by mail-vc0-f172.google.com with SMTP id hr11so2441170vcb.31
        for <linux-nfs@vger.kernel.org>; Thu, 04 Apr 2013 08:38:01 -0700 (PDT)
MIME-Version: 1.0
Reply-To: tigran.mkrtchyan@desy.de
In-Reply-To: <20130404151507.GA8484@umich.edu>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
Date: Thu, 4 Apr 2013 17:38:00 +0200
Message-ID: <CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
Subject: Re: readdir vs. getattr
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 4, 2013 at 5:15 PM, Jim Rees <rees@umich.edu> wrote:
> Tigran Mkrtchyan wrote:
>
>   we have a directory with 50K (number of )  files in it.
>   The user does a 'ls' and I can see READDIR4. To
>   get the complete listing a client need to send ~380 requests.
>   Now user does yet another 'ls' in the same directory.
>   The client sends a GETATTR  on directorie's FH
>   (actually two of GETATTRS - why?!!) and discovers that a
>   directory didn't change and re-uses existing listing, BUT!!!
>   for each file in the directory it sends a GETATTR to discover
>   is  the file's attributes are changed. For 50K files it's a 50K requests.
>
> So is this a "ls -l"? Because for "ls" it shouldn't stat all the files.

I believe it's 'ls -l'.  Well, you probably want to say that it's ls
calling stat on each file. Nevertheless client still should re-use
cached information.
