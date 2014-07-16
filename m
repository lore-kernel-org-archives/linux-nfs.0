Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:37119 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965255AbaGPOeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2014 10:34:25 -0400
Received: by mail-qc0-f182.google.com with SMTP id r5so839794qcx.27
        for <linux-nfs@vger.kernel.org>; Wed, 16 Jul 2014 07:34:24 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 16 Jul 2014 10:34:23 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] nfsd: Ensure stateids remain unique until they are
 freed
Message-ID: <20140716103423.041a89af@tlielax.poochiereds.net>
In-Reply-To: <20140716142928.GA9671@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
	<1405420669-4030-3-git-send-email-jlayton@primarydata.com>
	<20140715171547.GA5269@infradead.org>
	<20140716081738.05ce6d92@tlielax.poochiereds.net>
	<20140716134945.GA11961@infradead.org>
	<20140716102824.27eeb209@tlielax.poochiereds.net>
	<20140716142928.GA9671@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 16 Jul 2014 07:29:28 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Jul 16, 2014 at 10:28:24AM -0400, Jeff Layton wrote:
> > Unfortunately, that creates a pile of merge conflicts in the later
> > patches. I'll just go ahead and change that and resend all of the
> > delegation patches that Bruce hasn't merged yet. Stay tuned...
> 
> Just keep it as is if it's too painful.  This isn't really something
> that matters too much in the end.
> 

Too late, I went ahead and just did it...

-- 
Jeff Layton <jlayton@primarydata.com>
