Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:56929 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752320Ab1KRQwA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 11:52:00 -0500
Message-ID: <4EC68D29.7030005@Calva.COM>
Date: Fri, 18 Nov 2011 17:51:53 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: peter.staubach@emc.com
CC: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't spam kernel log with EKEYEXPIRED and EACCESS errors
References: <4EC685D1.2000900@Calva.COM> <5E6794FC7B8FCA41A704019BE3C70E8B9422FC09@MX31A.corp.emc.com>
In-Reply-To: <5E6794FC7B8FCA41A704019BE3C70E8B9422FC09@MX31A.corp.emc.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 18/11/11 17:27, peter.staubach@emc.com wrote:
> Given that the poor user will be sitting, with almost nothing working because of the expired ticket, how does the user figure out what is going on or how does the admin help him?
>
> Some guidance seems like a good thing.  Is there really a problem with these messages being printed to the log?
If you're sat at your console with nothing responding how are you going 
to see the log messages?

The "ticket expired" messages are rate limited.

The "Error: state manager failed on NFSv4 server" messages are not rate 
limited, but if you use my "rpc.gssd -e" hack they'll be written to the 
log every 5 seconds all night long.

