Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751934AbaAFL6T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Jan 2014 06:58:19 -0500
Date: Mon, 6 Jan 2014 06:58:15 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, ssorce@redhat.com, neilb@suse.de
Subject: Re: [PATCH 0/3] sunrpc: change handling of use-gss-proxy file
Message-ID: <20140106065815.70ff2c37@tlielax.poochiereds.net>
In-Reply-To: <20140105203045.GC22918@fieldses.org>
References: <1388837885-8312-1-git-send-email-jlayton@redhat.com>
	<20140105203045.GC22918@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 5 Jan 2014 15:30:45 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Sat, Jan 04, 2014 at 07:18:02AM -0500, Jeff Layton wrote:
> > This patchset fixes a couple of problems with the use-gss-proxy procfile
> > and does some general cleanup around that code. Bruce, can you consider
> > this for 3.14? Getting it into linux-next soon would be good too...
> 
> Yep, applied locally, should get pushed out tomorrow-ish.
> 
> I suppose the first should also go to stable if the "tar up /proc" case
> merits it.
> 
> The races look like they require pretty unusual userspace behavior, so
> I'm not inclined to backport those.
> 
> --b.
> 

Yeah, I think the first patch is probably reasonable for stable. There
are a number of tools that tar up /proc files in order to collect info
for troubleshooting and those are likely to get stuck with this.

The other two are theoretical races I noticed by inspection so I don't
think they would be appropriate for it.

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
