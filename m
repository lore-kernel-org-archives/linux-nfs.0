From: Timo Aaltonen <timo.aaltonen-uOixanVlb7U@public.gmane.org>
Subject: Re: session hangs with 2.6.33rc7 & nfs-utils 1.2.2rc9
Date: Fri, 4 Jun 2010 16:36:47 +0300
Message-ID: <alpine.DEB.2.00.1006041556450.9383@deckard.hut.fi>
References: <alpine.DEB.2.00.1002111604420.18032@kosh.hut.fi>  <1265897747.478.1.camel@localhost>  <alpine.DEB.2.00.1002111616470.18032@kosh.hut.fi>  <1265898673.478.3.camel@localhost>  <20100211102322.1581a385@barsoom.rdu.redhat.com>
 <alpine.DEB.2.00.1002112017550.18032@kosh.hut.fi>  <alpine.DEB.2.00.1002112114190.18032@kosh.hut.fi>  <20100211152822.622dcc70@barsoom.rdu.redhat.com>  <alpine.DEB.2.00.1002121410090.18032@kosh.hut.fi>  <alpine.DEB.2.00.1002121615290.18032@kosh.hut.fi>
 <20100212143249.GA17928@fieldses.org>  <alpine.DEB.2.00.1002121705390.18032@kosh.hut.fi>  <20100212111343.101fd0ce@tlielax.poochiereds.net>  <1265998794.2832.23.camel@localhost>  <alpine.DEB.2.00.1005061730460.3282@deckard.hut.fi> <1273165061.7699.39.camel@localhost.localdomain>
 <alpine.DEB.2.00.1005140942440.13223@deckard.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="US-ASCII"
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Jeff Layton <jlayton@redhat.com>
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx05.aalto.fi ([130.233.222.104]:56671 "EHLO mx05.aalto.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755399Ab0FDNo1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jun 2010 09:44:27 -0400
In-Reply-To: <alpine.DEB.2.00.1005140942440.13223-9o+TK994UVukEuhtYYxXtw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 14 May 2010, Timo Aaltonen wrote:

> On Thu, 6 May 2010, Trond Myklebust wrote:
>
>> On Thu, 2010-05-06 at 18:40 +0300, Timo Aaltonen wrote:
>>> Reviving the old thread, since it's still happening. Maybe I should file a
>>> proper bug about this?
>> 
>> Please do. Can you see if you can get a trace of the recovery thread?
>> Also, please check your dmesg log for any 'unhandled error' messages. If
>> there is nothing there, then we may have to get a 'wireshark' trace
>> too...
>
> Alright, here we go:
>
> https://bugzilla.kernel.org/show_bug.cgi?id=15973

Still the same with 2.6.34. I'm trying to reproduce it on Redhat/Fedora, 
but RHEL6 beta installation fails with a kernel panic, and F13 claims that 
the root ticket cache is "expired or corrupt" (created with 'kinit -k 
HOST$', looks just fine with klist). Logins work fine, just can't mount 
the share :) I tried to use 'nsupdate -g' and it complained the same, so 
I'm not sure what to blame.

I'm amazed that no-one else has complained so far, that's why I'd like to 
try if this happens on another recent distro as well..


-- 
Timo Aaltonen
Systems Specialist
Aalto University IT
