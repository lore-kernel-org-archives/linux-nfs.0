Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:51323 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754628AbaHNOfa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Aug 2014 10:35:30 -0400
Message-ID: <1408026925.2683.24.camel@joe-AO725>
Subject: Re: [PATCH] locks: Remove unused conf argument from lm_grant
From: Joe Perches <joe@perches.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christine Caulfield <ccaulfie@redhat.com>,
        David Teigland <teigland@redhat.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, cluster-devel@redhat.com,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Kinglong Mee <kinglongmee@gmail.com>
Date: Thu, 14 Aug 2014 07:35:25 -0700
In-Reply-To: <20140814095658.1716c48e@tlielax.poochiereds.net>
References: <1408024360-5177-1-git-send-email-jlayton@primarydata.com>
	 <20140814095658.1716c48e@tlielax.poochiereds.net>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-08-14 at 09:56 -0400, Jeff Layton wrote:
> On Thu, 14 Aug 2014 09:52:40 -0400
> Jeff Layton <jlayton@primarydata.com> wrote:
> > From: Joe Perches <joe@perches.com>
> > This argument is always NULL so don't pass it around.
> > Signed-off-by: Joe Perches <joe@perches.com>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> > ---
> >  fs/dlm/plock.c     |  8 ++++----
> >  fs/lockd/svclock.c | 12 +++---------
> >  include/linux/fs.h |  2 +-
> >  3 files changed, 8 insertions(+), 14 deletions(-)
> Joe, if this looks OK with you, I'll plan to merge this for v3.18.

Looks fine, thanks Jeff.


