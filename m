Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f182.google.com ([209.85.192.182]:50455 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbaEHViP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 May 2014 17:38:15 -0400
Received: by mail-pd0-f182.google.com with SMTP id v10so2829257pde.27
        for <linux-nfs@vger.kernel.org>; Thu, 08 May 2014 14:38:15 -0700 (PDT)
Date: Thu, 8 May 2014 14:38:11 -0700
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Push the file layout driver into a subdirectory
Message-ID: <20140508213811.GA1953@kitty.kitty>
References: <1399560525-1913-1-git-send-email-Thomas.Haynes@primarydata.com>
 <20140508134347.0c330f62@tlielax.poochiereds.net>
 <1582D06D-6663-49EC-A187-BF52FBCFAC39@primarydata.com>
 <20140508170621.2eccbafc@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140508170621.2eccbafc@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 08, 2014 at 05:06:21PM -0400, Jeff Layton wrote:
> > 
> > Strange, I'll resend it.
> > 
> 
> Maybe it hit some sort of size limitation? I didn't think linux-nfs had
> one of those, but some ml's do.

Yes, that was it. "git format -M" solved it for me.

Thanks.

