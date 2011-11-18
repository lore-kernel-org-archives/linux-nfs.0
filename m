Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:55015 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756440Ab1KRNvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 08:51:32 -0500
Message-ID: <4EC662DC.70001@Calva.COM>
Date: Fri, 18 Nov 2011 14:51:24 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket
 expiry
References: <4EC6426A.3020306@Calva.COM> <4EC66148.4020003@RedHat.com>
In-Reply-To: <4EC66148.4020003@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18/11/11 14:44, Steve Dickson wrote:
>
> I think the answer to all this is have the ticket
> renewed before it expires. There is a daemon call sssd
> that is part of the FreeIPA project that will supposedly
> do that for us... I'm looking into it...
You can only renoew the ticket before it expires if it hasn't yet expired.

Imagine this case:

I go home for the evening.

The screensaver kicks in.

The machine suspends to ram.

The ticket expires.  Yes, it was renewable but nobody could renew it 
because they were asleep.

I come back the next morning, hit a key, the unlock screen pops up, I 
enter my password, pam_krb5 gets a new ticket.


