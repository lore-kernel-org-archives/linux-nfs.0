From: Chip Salzenberg <chip@pobox.com>
Subject: Re: nfs-utils-1.0.5 is not backwards compatible with 2.4
Date: Fri, 1 Aug 2003 10:38:07 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20030801143807.GB24358@perlsupport.com>
References: <3F294DE3.9020304@RedHat.com> <16169.54918.472349.928145@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16169.54918.472349.928145@gargle.gargle.HOWL>
List-ID: <nfs.lists.sourceforge.net>

According to Neil Brown:
> I don't know if there is any such code, but if there is I apoligize for
> breaking it and suggest that the best fix is to not use the header
> file it was using but it explicitly include the values for NFSEXP_* in
> that code.

The only really bad thing about the current situation is that the name
"NFSEXP_CROSSMNT" is poisoned by having had two historical
definitions.  So it that name should be dropped, IMO, and replaced by
something textually different.  "NFSEXP_XMOUNT", perhaps.  Even
"NFSEXP_CROSSMNT2" would work.  Just as long as code that said
"CROSSMNT" to mean "NOHIDE" wouldn't accidentally get CROSSMNT instead.
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K
