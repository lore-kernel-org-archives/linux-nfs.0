From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 1/4] Optimize NFS open() calls by means of 'intents'...
Date: Tue, 1 Jul 2003 11:39:41 +0200
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <16129.22237.385862.74120@charged.uio.no>
References: <16128.19197.159225.698080@charged.uio.no>
	<20030630151426.GG31618@parcelfarce.linux.theplanet.co.uk>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux FSdevel <linux-fsdevel@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Matthew Wilcox <willy@debian.org>
In-Reply-To: <20030630151426.GG31618@parcelfarce.linux.theplanet.co.uk>
List-ID: <nfs.lists.sourceforge.net>


     > Can we call the union something descriptive (eg "intent")
     > rather than "u"?

Sure. I'm fine with substutiting 'intent' for 'u' in the final version.

Any other comments/objections/... before I push this on to Linus?

Cheers,
  Trond
