Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50845 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752741Ab3KBOhk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 2 Nov 2013 10:37:40 -0400
Date: Sat, 2 Nov 2013 10:37:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131102143729.GA26983@fieldses.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
 <20131029073558.GA10889@infradead.org>
 <526FB180.1060003@netapp.com>
 <20131029130721.GA32094@infradead.org>
 <20131029133006.GB29606@fieldses.org>
 <20131102134837.GA18961@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131102134837.GA18961@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Nov 02, 2013 at 06:48:37AM -0700, Christoph Hellwig wrote:
> On Tue, Oct 29, 2013 at 09:30:06AM -0400, J. Bruce Fields wrote:
> > I haven't read these parts of the spec yet at all....
> 
> Btw, is there a way do to something like a git blame for the spec?  I'd
> really love to confront people personally with some of the odd bits they
> came up with.

It *is* in git, so you can literally run git blame:

	https://github.com/loghyr/NFSv4.2

But it'll probably credit almost everything to Tom and he's typically
just the messenger....

Just direct gripes to nfsv4@ietf.org.  They also take patches.

--b.
