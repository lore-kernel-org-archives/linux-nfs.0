Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:37922 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab2DPTmm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Apr 2012 15:42:42 -0400
Message-ID: <4F8C7648.8000701@gmail.com>
Date: Mon, 16 Apr 2012 15:43:04 -0400
From: Scott Lovenberg <scott.lovenberg@gmail.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>,
        Malahal Naineni <malahal@us.ibm.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        pstaubach@exagrid.com, miklos@szeredi.hu, viro@ZenIV.linux.org.uk,
        hch@infradead.org, michael.brantley@deshaw.com,
        sven.breuner@itwm.fraunhofer.de
Subject: Re: [PATCH RFC] vfs: make fstatat retry on ESTALE errors from getattr
 call
References: <1334316311-22331-1-git-send-email-jlayton@redhat.com>	<20120413150518.GA1987@us.ibm.com>	<20120413114236.0e557e01@tlielax.poochiereds.net>	<4F8B1B7B.3040304@itwm.fraunhofer.de>	<20120416073655.7cdb90cf@corrin.poochiereds.net>	<4F8C3036.2030702@itwm.fraunhofer.de> <20120416134642.1754cd3e@corrin.poochiereds.net>
In-Reply-To: <20120416134642.1754cd3e@corrin.poochiereds.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 4/16/2012 1:46 PM, Jeff Layton wrote:
> NFS will generally return a different error if the process catches a
> fatal signal, so a soft mount should not be necessary and is not
> recommended anyway...
>
> In any case, we loop indefinitely now in the NFS code when (for
> instance) there's a loss of communication. Users are not generally
> happy if that causes an error, since their applications start dying.
>
 From the peanut gallery, I've always set an infinite loop with an 
exponential backoff on the loss of communication.  IE, in some code I 
wrote for S3backer (a FUSE file system on top of Amazon EC3) a few years 
ago (committed by Archie Cobbs).

The trade off is that your applications will try to submit requests if 
you don't tell them "leave me alone, I can't service you now".  The more 
I think about it, the more it seems like failing silently.  Isn't the 
rule supposed to be "if you must fail, do it loudly and as soon as 
possible"?  Just my $0.02.  Take it as you will.
