Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55128 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986AbaHZN7V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2014 09:59:21 -0400
Date: Tue, 26 Aug 2014 06:59:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        bfields@fieldses.org, cluster-devel@redhat.com,
        linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/10] locks/nfsd: internal lease API overhaul
Message-ID: <20140826135920.GB18599@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <20140824161046.GI15908@infradead.org>
 <20140824214301.61019123@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140824214301.61019123@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 24, 2014 at 09:43:01PM -0400, Jeff Layton wrote:
> >  - add a return value to lm_break so that the lock manager can tell the
> >    core code "you can delete this lease right now".  That gets rid of
> >    the games with the timeout which require all kinds of race avoidance
> >    code in the users.
> > 
> 
> I'm not sure I understand what you're suggesting here. Isn't it just as
> simple to have lm_break call lease_modify to just remove the lease?

Unfortunately it's not.  lm_break gets a pointer to the file_lock,
and lease_modify needs a pointer to the list position of the file_lock.
