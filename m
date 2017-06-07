Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56189 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751424AbdFGJml (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Jun 2017 05:42:41 -0400
Subject: Re: [systemd-devel] [PATCH] nfs.man: document incompatibility between
 "bg" option and systemd.
To: Lennart Poettering <mzxreary@0pointer.de>,
        Michael Biebl <mbiebl@gmail.com>
Cc: linux-nfs@vger.kernel.org, systemd-devel@freedesktop.org,
        NeilBrown <neilb@suse.com>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <89415cad-331e-bac6-7fd1-dffa058726de@RedHat.com>
 <CAGWsdOjswhfUszn0AmFtFcz-sbDU8=qFr5z1=tNigROOPBS0Rw@mail.gmail.com>
 <20170607081313.GI27006@gardel-login>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <7da2b587-b21a-48ad-6ab4-2a1efed25d65@RedHat.com>
Date: Wed, 7 Jun 2017 05:42:39 -0400
MIME-Version: 1.0
In-Reply-To: <20170607081313.GI27006@gardel-login>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/07/2017 04:13 AM, Lennart Poettering wrote:
> On Tue, 06.06.17 21:57, Michael Biebl (mbiebl@gmail.com) wrote:
> 
>> 2017-06-06 20:07 GMT+02:00 Steve Dickson <SteveD@redhat.com>:
>>> Finally, the whole idea of systemd randomly/silently
>>> strip off mount options is crazy... IMHO...
>>
>> Personally, I would prefer if systemd simply logged a warning/error
>> message but would *not* strip the bg option.
> 
> What good does that do if "bg" doesn't actually work properly?
At the moment it works just fine... 

steved.

> 
> Lennart
> 
