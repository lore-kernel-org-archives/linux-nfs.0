Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-3.hut.fi ([130.233.228.93]:45738 "EHLO smtp-3.hut.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359Ab0ENGnp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 02:43:45 -0400
Date: Fri, 14 May 2010 09:43:22 +0300 (EEST)
From: Timo Aaltonen <timo.aaltonen@aalto.fi>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>
Subject: Re: session hangs with 2.6.33rc7 & nfs-utils 1.2.2rc9
In-Reply-To: <1273165061.7699.39.camel@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1005140942440.13223@deckard.hut.fi>
References: <alpine.DEB.2.00.1002111604420.18032@kosh.hut.fi>  <1265897747.478.1.camel@localhost>  <alpine.DEB.2.00.1002111616470.18032@kosh.hut.fi>  <1265898673.478.3.camel@localhost>  <20100211102322.1581a385@barsoom.rdu.redhat.com>
 <alpine.DEB.2.00.1002112017550.18032@kosh.hut.fi>  <alpine.DEB.2.00.1002112114190.18032@kosh.hut.fi>  <20100211152822.622dcc70@barsoom.rdu.redhat.com>  <alpine.DEB.2.00.1002121410090.18032@kosh.hut.fi>  <alpine.DEB.2.00.1002121615290.18032@kosh.hut.fi>
 <20100212143249.GA17928@fieldses.org>  <alpine.DEB.2.00.1002121705390.18032@kosh.hut.fi>  <20100212111343.101fd0ce@tlielax.poochiereds.net>  <1265998794.2832.23.camel@localhost>  <alpine.DEB.2.00.1005061730460.3282@deckard.hut.fi>
 <1273165061.7699.39.camel@localhost.localdomain>
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 6 May 2010, Trond Myklebust wrote:

> On Thu, 2010-05-06 at 18:40 +0300, Timo Aaltonen wrote:
>> Reviving the old thread, since it's still happening. Maybe I should file a
>> proper bug about this?
>
> Please do. Can you see if you can get a trace of the recovery thread?
> Also, please check your dmesg log for any 'unhandled error' messages. If
> there is nothing there, then we may have to get a 'wireshark' trace
> too...

Alright, here we go:

https://bugzilla.kernel.org/show_bug.cgi?id=15973

-- 
Timo Aaltonen
Systems Specialist
IT Services, Aalto University
