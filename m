Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mexforward.lss.emc.com ([128.222.32.20]:56475 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab1KRRvR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 12:51:17 -0500
From: <peter.staubach@emc.com>
To: <john@Calva.COM>
CC: <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Date: Fri, 18 Nov 2011 12:50:38 -0500
Subject: RE: [PATCH] Don't spam kernel log with EKEYEXPIRED and EACCESS
 errors
Message-ID: <5E6794FC7B8FCA41A704019BE3C70E8B9422FC49@MX31A.corp.emc.com>
References: <4EC685D1.2000900@Calva.COM>
 <5E6794FC7B8FCA41A704019BE3C70E8B9422FC09@MX31A.corp.emc.com>
 <4EC68D29.7030005@Calva.COM>
In-Reply-To: <4EC68D29.7030005@Calva.COM>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The log messages are for the poor admin who has to figure out why nothing is working for the user.

		ps


-----Original Message-----
From: John Hughes [mailto:john@Calva.COM] 
Sent: Friday, November 18, 2011 11:52 AM
To: Staubach, Peter
Cc: Trond.Myklebust@netapp.com; linux-nfs@vger.kernel.org; linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't spam kernel log with EKEYEXPIRED and EACCESS errors

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


