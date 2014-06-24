Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:60383 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbaFXME2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jun 2014 08:04:28 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so142642qac.13
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jun 2014 05:04:27 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 24 Jun 2014 08:04:26 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 011/104] NFSd: Lock owners are not per open stateid
Message-ID: <20140624080426.75799943@tlielax.poochiereds.net>
In-Reply-To: <20140624115058.GA31935@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-12-git-send-email-jlayton@primarydata.com>
	<20140624115058.GA31935@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 24 Jun 2014 04:50:58 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> FYI, this is what I think should go into a separate inintial series.
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Yeah, I was thinking about that last night. I think the parts that could
be broken out are:

- the change to multiple stateids per lockowner
- moving some of the fields into nfs4_stid
- adding refcounting for stateids and stateowners and fixing the
  relationships between them

Unfortunately, that means a pretty significant respin of the set as a
lot of the changes now are mashed in with those that add locking around
those parts. I'll give it some more thought...
-- 
Jeff Layton <jlayton@primarydata.com>
