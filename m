Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63523 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753565Ab2E1Rz7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 May 2012 13:55:59 -0400
Received: by wibhj8 with SMTP id hj8so1910856wib.1
        for <linux-nfs@vger.kernel.org>; Mon, 28 May 2012 10:55:58 -0700 (PDT)
Message-ID: <4FC3BC2B.6060709@tonian.com>
Date: Mon, 28 May 2012 20:55:55 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Does our Kernel PNFSD-Server supports recurring layout_get with
 open_state_id
References: <4FBD7DE8.9090002@panasas.com> <4FBE2C8C.9090403@tonian.com> <4FBE3C4D.7050507@panasas.com> <4FC3A235.8090908@tonian.com> <4FC3A974.60107@panasas.com>
In-Reply-To: <4FC3A974.60107@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-05-28 19:36, Boaz Harrosh wrote:
> On 05/28/2012 07:05 PM, Benny Halevy wrote:
> 
>> Yup, see patchset in reply.
>>
> 
> 
> That I wish you wouldn't do. I have a patchset pending that makes
> major changes to all this and totally conflicts with your code.

Sorry, I didn't know that.

> 
> You can carry this for a while but I might revert your core
> code in my new patchset.

I hope that at least it will all be for the better.

Benny

> 
> Sigh, more work for me.
> 
> Boaz
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
