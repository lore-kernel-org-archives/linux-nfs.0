Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-3.MIT.EDU ([18.9.25.14]:50396 "EHLO
	dmz-mailsec-scanner-3.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755849Ab1G1VY4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 17:24:56 -0400
Message-ID: <20110728172449.8wxxte4jg0s8kcgs@webmail.mit.edu>
Date: Thu, 28 Jul 2011 17:24:49 -0400
From: Gregory Magoon <gmagoon@MIT.EDU>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
References: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu>
	<1311886684.27285.8.camel@lade.trondhjem.org>
In-Reply-To: <1311886684.27285.8.camel@lade.trondhjem.org>
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks for the tips...unfortunately, making the changes you suggest (removing
timeo, rsize, wsize options) doesn't seem to address the issue with MPICH2 and
NFSv4.

Greg

Quoting Trond Myklebust <Trond.Myklebust@netapp.com>:
>
> This is getting to be a FAQ...
>
> 2 second timeouts over TCP are just plain wrong: they will cause you to
> continuously disconnect and reconnect (as 'netstat -t' is bound to show
> you). Please don't muck with the default timeo=600.
>
> There is also no reason to mess with rsize and wsize: allow the client
> and server to autonegotiate.
>


