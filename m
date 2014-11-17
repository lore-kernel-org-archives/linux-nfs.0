Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34641 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbaKQTJe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Nov 2014 14:09:34 -0500
Message-ID: <546A47EA.9090707@RedHat.com>
Date: Mon, 17 Nov 2014 14:09:30 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Henrique Martins <linux@martins.cc>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] nfsd/exportfs: allow empty exports file
References: <17903.1415988313@monster.martins.cc> <5469F395.9080701@RedHat.com> <29411.1416239616@monster.martins.cc>
In-Reply-To: <29411.1416239616@monster.martins.cc>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please take a look at what I committed today to 
see it it works in your environment. We'll work
on it if it does not... 

steved.

On 11/17/2014 10:53 AM, Henrique Martins wrote:
> steved> The presidence has been set that having an empty
> steved> export file is not a problem. So I would rather
> steved> change that xlog to be a L_WARNING and only log it
> steved> when the verbose is set.
> 
> The situation, PRECEDENCE, when I got involved was:
>   no entries in exports:
>     nothing logged, nfsd started
>   all good entries in exports
>     nothing logged, nfsd started
>   mixture of bad and good entries in exports
>     bad entries logged, error logged, nfsd aborted
>   all bad entries in exports
>     bad entries logged, error logged, nfsd aborted
> 
> My first patch overlooked that first condition, and made the
> situation like below, changed from PRECEDENCE uppercased:
>   no entries in exports:
>     EMPTY LOGGED, NFSD ABORTED
>   all good entries in exports
>     nothing logged, nfsd started
>   mixture of bad and good entries in exports
>     bad entries logged, NFSD STARTED
>   all bad entries in exports
>     bad entries logged, error logged, nfsd aborted
> 
> Current patch makes it, changes from PRECEDENCE uppercased:
>   no entries in exports:
>     nothing logged, nfsd started
>   all good entries in exports
>     nothing logged, nfsd started
>   mixture of bad and good entries in exports
>     bad entries logged, NFSD STARTED
>   all bad entries in exports
>     bad entries logged, error logged, nfsd aborted
> 
> Your patch makes it, changes from PRECEDENCE uppercased:
>   no entries in exports:
>     WARNING LOGGED, nfsd started
>   all good entries in exports
>     nothing logged, nfsd started
>   mixture of bad and good entries in exports
>     bad entries logged, NFSD STARTED
>   all bad entries in exports
>     bad entries logged, NFSD STARTED
> 
> Your pick,
> 
> -- Henrique
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
