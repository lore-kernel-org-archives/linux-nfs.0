Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f46.google.com ([209.85.219.46]:41874 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759426Ab2JaRnf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2012 13:43:35 -0400
Received: by mail-oa0-f46.google.com with SMTP id h16so1704792oag.19
        for <linux-nfs@vger.kernel.org>; Wed, 31 Oct 2012 10:43:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <k6rgcc$igt$1@ultimate100.geggus.net>
References: <k6ebva$1kf$1@ultimate100.geggus.net>
	<20121026171549.GA11806@fieldses.org>
	<20121029094038.GA14836@geggus.net>
	<20121029150203.GB9502@fieldses.org>
	<20121029163323.GA24345@geggus.net>
	<k6r6ur$eva$2@ultimate100.geggus.net>
	<CAA7C2qiiHzwMmkm5fUyNCffejxACtsDu0Pb1qgYJPCfgcaZU-w@mail.gmail.com>
	<k6rgcc$igt$1@ultimate100.geggus.net>
Date: Wed, 31 Oct 2012 10:43:34 -0700
Message-ID: <CAA7C2qhaKE7tAcsfNn0_jZ3BgWbFM6FkH1s0z+hd3JfOELywuQ@mail.gmail.com>
Subject: Re: Kernel update 3.5.7 -> 3.6.3 breaks NFS4
From: VDR User <user.vdr@gmail.com>
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 31, 2012 at 8:33 AM, Sven Geggus
<lists@fuchsschwanzdomain.de> wrote:
>> In case you missed my previous message, "I use debian testing here and
>> NFSv4. My clients are running kernel 3.6.3, server is running 3.6.2.  No
>> problems here".
>
> No, I did not miss your post. I even asked if you are using sec=krb5. I did
> not try if it works without using kerberos, because I am not interested in
> "No File Security" NFS3-like mode.

Ahh sorry. I misread your post and thought it was directed towards
someone else. No, I'm not using sec=krb5.

>> It would seem you only need to cherry-pick server changes between 3.6.2
>> and 3.6.3...?
>
> Unfortunately not. It already did not work using 3.6.2

You could always write a simple script to download & compile each
kernel inbetween that range, then just boot into each and find where
the breakage occured that way. Sometimes its easier than sifting
through a sea of changes. :)
