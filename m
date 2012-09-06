Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailservice.tudelft.nl ([130.161.131.5]:35482 "EHLO
	mailservice.tudelft.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753875Ab2IFHaZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Sep 2012 03:30:25 -0400
Received: from localhost (localhost [127.0.0.1])
	by amavis (Postfix) with ESMTP id D47BE2B8038
	for <linux-nfs@vger.kernel.org>; Thu,  6 Sep 2012 09:30:23 +0200 (CEST)
Received: from mailservice.tudelft.nl ([130.161.131.73])
	by localhost (tudelft.nl [127.0.0.1]) (amavisd-new, port 10026)
	with ESMTP id hqg7j6-FnAFn for <linux-nfs@vger.kernel.org>;
	Thu,  6 Sep 2012 09:30:23 +0200 (CEST)
Received: from smtp-a.tudelft.nl (smtp-a.tudelft.nl [130.161.180.7])
	by mx2.tudelft.nl (Postfix) with ESMTP id 11DEA2B801A
	for <linux-nfs@vger.kernel.org>; Thu,  6 Sep 2012 09:30:23 +0200 (CEST)
Received: from pc-rsmits.ws.tudelft.net (x081242.tudelft.net [131.180.81.242])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-a.tudelft.nl (Postfix) with ESMTP id 05BD8B3A62
	for <linux-nfs@vger.kernel.org>; Thu,  6 Sep 2012 09:30:22 +0200 (CEST)
Message-ID: <5048510E.4080407@tudelft.nl>
Date: Thu, 06 Sep 2012 09:30:22 +0200
From: Richard Smits <R.Smits@tudelft.nl>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: nfsv4 state id errors
References: <503B49E4.2050409@tudelft.nl>
In-Reply-To: <503B49E4.2050409@tudelft.nl>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Anyone any ideas ? Or should we open a case at Netapp ?

Greetings.

On 08/27/2012 12:20 PM, Robbert Eggermont wrote:
> Hello,
>
>> A couple of weeks agoo we upgraded our Netapp filer to 8.1.1RC1. We have
>> always had trouble with NFS and state id's. Resulting in hanging clients.
>
> (Client: SLED11 SP2, 3.0.34-0.7-default x86_64)
>
> The "hanging" seems to be caused by the server returning an
> NFS4ERR_BAD_STATEID(10025) status for PUTFH;LOCK and PUTFH;WRITE;GETATTR
> calls. The client is making several hundreds of these identical (same
> filehandle) calls each second.
>
> The problem seems to be triggered by (write) actions on an open file
> when the Kerberos ticket has expired (especially for .xsession-errors
> and files opened by Firefox or Thunderbird).
>
> When (after some time) a new valid ticket is obtained, the kernel
> reports this error:
> nfs4_reclaim_open_state: unhandled error -10026. Zeroing state
>
> Is this a client or a server problem (and is there by any chance a fix)?
>
> Robbert
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
