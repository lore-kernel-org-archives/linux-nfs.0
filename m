Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45547 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754353Ab2B2WcS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 17:32:18 -0500
Date: Wed, 29 Feb 2012 17:32:17 -0500
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org, Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Subject: Re: NFSv4 client restriction
Message-ID: <20120229223216.GB6506@fieldses.org>
References: <CAO9xhuZ+2VsTog1bqomC82jVfNFVOx6JTGgG+muDQsFu_5R7ZA@mail.gmail.com>
 <20120223010111.GA19432@fieldses.org>
 <4F45E63B.9090608@steve-ss.com>
 <4F464A4A.10403@fifthhorseman.net>
 <4F465E76.4000201@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F465E76.4000201@steve-ss.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2012 at 04:42:46PM +0100, steve wrote:
> On 02/23/2012 03:16 PM, Daniel Kahn Gillmor wrote:
> >On 02/23/2012 02:09 AM, steve wrote:
> >>It is not recommended to use the pseudoroot fsid=0 stuff for Linux.
> >>
> >>See the nfs wiki: 'The linux implementation allows you to designate a
> >>real filesystem as the pseudofilesystem, identifying that export with
> >>the fsid=0 option; we no longer recommend this. Instead, on any recent
> >>linux distribution, just list exports in /etc/exports exactly as you
> >>would for NFSv2 or NFSv3.'
> >I believe the last time this came up, i asked for a rationale or
> >explanation.  The only reason given [0] was from J. Bruce Fields:
> I've never got to the bottom of this one either. I only know that it works.
> >>>The main problem with the fsid=0 trick is that your v3 and v4 clients
> >>>end up with different paths.
> But if say, you're exporting /home and have /home bind mounted to
> your pseudoroot, then the paths are exactly the same. You still
> mount -t nfsx server:/home /client/somewhere for x=3 or x=4. No?

I suppose that'll work, though it's a little messy: if someone looks at
your exports e.g.  with shomwount it'll look like:

	# showmount -e myserver
	export list for myserver:
	/home *
	/path/to/pseudoroot/home *

And v4 clients who try to mount the latter will get an error.

--b.

> >So, if you have no v3 clients, i don't think there is any reason to
> >avoid fsid=0 if it makes things cleaner for you.  And removing fsid=0
> >will require you to change /etc/fstab (or your automounter config) in
> >all of your clients.
> Please accept my apologies for butting in on this. I'm simply trying
> to get some facts together.
> Cheers,
> Steve
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
