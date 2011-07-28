Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from DMZ-MAILSEC-SCANNER-6.MIT.EDU ([18.7.68.35]:43282 "EHLO
	dmz-mailsec-scanner-6.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752461Ab1G1WBg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jul 2011 18:01:36 -0400
Message-ID: <20110728180120.bf6gq5zyos8wwg4s@webmail.mit.edu>
Date: Thu, 28 Jul 2011 18:01:20 -0400
From: Gregory Magoon <gmagoon@MIT.EDU>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 vs NFSv3 with MPICH2-1.4
References: <20110728152306.219iz5wpkcokoo4c@webmail.mit.edu>
	<1311886684.27285.8.camel@lade.trondhjem.org>
	<20110728172449.8wxxte4jg0s8kcgs@webmail.mit.edu>
	<1311889677.27285.14.camel@lade.trondhjem.org>
In-Reply-To: <1311889677.27285.14.camel@lade.trondhjem.org>
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I'll try this the next time I get a chance.

Just to be clear, I don't think it is a performance issue; I think it is just
getting stuck.

Greg

Quoting Trond Myklebust <Trond.Myklebust@netapp.com>:


> Have you turned off delegations on the server? I wouldn't expect them to
> help much on an MPI workload.
>

