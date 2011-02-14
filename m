Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.0.fullrate.dk ([90.184.12.24]:43561 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893Ab1BNVHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 16:07:48 -0500
Message-ID: <4D59999E.9040302@krogh.cc>
Date: Mon, 14 Feb 2011 22:07:42 +0100
From: Jesper Krogh <jesper@krogh.cc>
To: Jan Kara <jack@suse.cz>
CC: linux-kernel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: sync hangs - 2.6.35.10
References: <4D47A99A.6050204@krogh.cc> <20110201121457.GA2059@quack.suse.cz>
In-Reply-To: <20110201121457.GA2059@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-02-01 13:14, Jan Kara wrote:
>    Definitely. There have been several patches fixing livelock issues
> in this area under various conditions. Considering your use case, you
> might be hit by problems being fixed by commits:
> 6585027a5e8cb490e3a761b2f3f3c3acf722aff2
> aa373cf550994623efb5d49a4d8775bafd10bbc1
> b9543dac5bbc4aef0a598965b6b34f6259ab9a9b
> (went into 2.6.38-rc1)
I couldn't get above to apply on a 2.6.35.10 kernel, but applied to
a 2.6.37 the problem seems solved. Have they been queued up for stable?
> possibly also older
> 7624ee72aa09334af072853457a5d46d9901c3f8
> (in 2.6.36-rc1)
This one alone applied to 2.6.35 didn't solve it.

jk@clyde:~$ time sync

real    19m2.650s
user    0m0.000s
sys    0m0.030s

Without notable disk-activity while waiting. (<5MB/s measured using dstat)
This sample was "decent" I've seen sync times over 2 horus on this system
with 128GB of memory.. again without any notable disk-activity while 
waiting.

Thanks for your prompt response.

-- 
Jesper
