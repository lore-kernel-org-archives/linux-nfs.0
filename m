Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35588 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754377AbcDKQl6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Apr 2016 12:41:58 -0400
Date: Mon, 11 Apr 2016 12:41:54 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Tushar Shinde'" <mtk.tushar@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [Nfs-ganesha-devel] NFSv4 open close operations are slow
 compared to Linux kernel NFSv4
Message-ID: <20160411164154.GG4479@fieldses.org>
References: <CABQpAL4yG5P2M1SVX1sYRm_HQKMWS-06R7O+4wmd61WH1Fo4Sg@mail.gmail.com>
 <20160408211526.GC25179@fieldses.org>
 <CABQpAL5w=2nAUO0kOuR+pjo3q=9PCwO-QCCNAaTWAZU_r1nZEA@mail.gmail.com>
 <00f201d19408$87499250$95dcb6f0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <00f201d19408$87499250$95dcb6f0$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(Moving discussion to linux-nfs list, as it's no longer a Ganesha
issue.)

On Mon, Apr 11, 2016 at 08:40:50AM -0700, Frank Filz wrote:
> Use of async on knfsd is not fair to use in performance evaluation. I have
> long lobbied for renaming the async option to "I don't care about my data."

Yes, renaming might be doable.  "I_dont_care_about_my_data" is a little
cumbersome.  I'm not sure what's best.  Maybe "unsafe_commit"?  Though
that might give the incorrect impression it's just about the commit
operation.

I'm not sure how to manage the transition.

	- Even if they're using "async", they don't deserve to have
	  their server suddenly break on upgrade, so we need to continue
	  to respect "async" in existing /etc/exports files.
	- Are there scripts that scan exports for "sync" or "async"
	  options anywhere, and how might they go wrong?  Maybe I'm
	  overthinking this.

Maybe it'd be good enough to:

	- keep kernel interfaces the same.
	- in nfs-utils, use "unsafe_commit" in all output in place of
	  "async".  Accept "async" as a synonym, but possibly warn that
	  it's been renamed.

--b.
