From: Rik van Riel <riel@redhat.com>
Subject: Re: [NFS] [PATCH] kNFSd: Fixes a problem with inode clean up for
 vxfs
Date: Wed, 6 Aug 2003 13:08:01 -0400 (EDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0308061306380.18793-100000@chimarrao.boston.redhat.com>
References: <3F3128A4.8030305@RedHat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Neil Brown <neilb@cse.unsw.edu.au>, <nfs@lists.sourceforge.net>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F3128A4.8030305@RedHat.com>
List-ID: <nfs.lists.sourceforge.net>

On Wed, 6 Aug 2003, Steve Dickson wrote:

> This a patch I've received from Veritas. Supposedly they have
> already submitted this but I can't seem to find it in any 2.4 trees..
> 
> Does anybody recognize this and are there any known issues with it?

It makes me wonder what is so special about vxfs that they need
to modify GPL code in order for it to work ...

Not that I'm against this change in principle, but I'd just like
it to be useful for GPL software too, otherwise it'd just be a
hook for non-GPL software and a fine line to a GPL violation.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
