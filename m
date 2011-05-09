Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:36891 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753484Ab1EIQyt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 12:54:49 -0400
Message-ID: <4DC81C50.6010507@panasas.com>
Date: Mon, 09 May 2011 19:54:40 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: niujin <pippo.oxford@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs's interface and unix fs system call
References: <4DC8D37D.20800@gmail.com>
In-Reply-To: <4DC8D37D.20800@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-10 08:56, niujin wrote:
> Hi everyone, I'm new to nfs and I read a line of words refering to NFS 
> in <Distributed Systems --- Concepts and Design>:
> "User programs can access files via Unix system calls without 
> recompilication or reloading"
> 
> My question is, as far as I know, unix system call include "open" 
> operation while NFS server operation does not, it seems to be 
> contradictary to the quotings above, why?

The NFS version 2 and 3 protocols are stateless and are not
intended to export all Unix/Posix system calls therefore they
include no OPEN operation.

The client uses LOOKUP to get a file handle which is used
by other operations to identify the file at hand somewhat similar
to the way an open file descriptor is used by Posix system calls
(just without any state associated with it)

Benny
