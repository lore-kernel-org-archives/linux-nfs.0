Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35476 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932131AbdGJP1A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 10 Jul 2017 11:27:00 -0400
Subject: Re: [PATCH] nfs.man: document incompatibility between "bg" option and
 systemd.
To: NeilBrown <neilb@suse.com>
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org,
        Lennart Poettering <lennart@poettering.net>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name>
 <20170529133814.GC17967@gardel-login>
 <87tw43fgrf.fsf@notabene.neil.brown.name>
 <87zicjyhby.fsf@notabene.neil.brown.name>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <8403677d-cb85-41b2-3c9c-179b82928b80@RedHat.com>
Date: Mon, 10 Jul 2017 11:26:54 -0400
MIME-Version: 1.0
In-Reply-To: <87zicjyhby.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Neil,

On 07/04/2017 06:20 PM, NeilBrown wrote:
> On Tue, May 30 2017, NeilBrown wrote:
> 
>> Systemd does not, and will not, support "bg" correctly.
>> It has other, better, ways to handle "background" mounting.
> 
> For those who aren't closely watching systemd development, a
> patch was recently accepted which causes systemd to work correctly with
> NFS bg mounts.  So the above "and will not" was, happily, not correct.
Could you please post a pointer to the thread?

tia,

steved.
