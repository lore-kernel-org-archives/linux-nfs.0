Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:59291 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070Ab1KRW4p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 17:56:45 -0500
Message-ID: <4EC6E2DE.6050700@calvaedi.com>
Date: Fri, 18 Nov 2011 23:57:34 +0100
From: John Hughes <john@calvaedi.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: John Hughes <john@calva.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry. Try 2 with added man pages.
References: <4EC66D12.2090505@Calva.COM>		 <1321641333.2653.15.camel@lade.trondhjem.org>		 <4EC6AFA9.9000705@calvaedi.com>	 <1321648435.2653.53.camel@lade.trondhjem.org>	 <4EC6D767.6030109@calvaedi.com> <1321655886.10541.24.camel@lade.trondhjem.org>
In-Reply-To: <1321655886.10541.24.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/18/2011 11:38 PM, Trond Myklebust wrote:
> The fact of the matter is that most application writers remain blithely
> oblivious of the need to fsync() as the ext4 people know all to well:
> see the attempts to impose the fully posix-compatible 'data=writeback'
> mode as the default and the catastrophe that occurred when
> 'data=ordered' semantics changed for the rename() syscall. Adding new
> failure modes needs to be done with care, or GNOME will crash and/or
> your word processor _will_ lose your last hour or so of work.
>    
1. It's not a new failure mode.  it's how things worked before 2.6.34
2. My ticket usualy expires in the middle of the night.  I get back in 
the morning and have to reboot the workstation because it's hung.  
Anything left in the wordprocessor is lost.

Before this change I got back in the morning, the unlock screen popped 
up, I entered my password and got a new ticket, everyone was happy.
