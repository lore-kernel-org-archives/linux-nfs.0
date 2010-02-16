From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: 2.6.32.2 - WARNING: at lib/kref.c:43 kref_get+0x,23/0x2b()
Date: Tue, 16 Feb 2010 15:29:47 -0500
Message-ID: <20100216202947.GF26292@fieldses.org>
References: <4B4F5A00.4060604@atmos.washington.edu> <20100122150325.6ad12428.akpm@linux-foundation.org> <20100127190522.GB18278@fieldses.org> <4B60C5D4.6070000@atmos.washington.edu> <20100202162228.GD4293@fieldses.org> <20100216182248.GA4922@nik-comp.linuxbox.cz> <20100216202121.GE26292@fieldses.org> <20100216202720.GB4922@nik-comp.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harry Edmon <harry-qmPYOCrcNLLyFCzt5hm0YvZ8FUJU4vz8@public.gmane.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	nikola.ciprich-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org
To: Nikola Ciprich <extmaillist-Jp3n8lUXroTtwjQa/ONI9g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54234 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933193Ab0BPU3J (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Feb 2010 15:29:09 -0500
In-Reply-To: <20100216202720.GB4922-YtsXe8XL0VS8z6Q06MQEFCF40CQGThNF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 16, 2010 at 09:27:20PM +0100, Nikola Ciprich wrote:
> > Nothing yet.  I'm taking another look.
> > 
> > Do you know what the most recent version was where you did *not* see
> > these warnings?
> well, actually I decided I'll bisect this one no matter what, so hopefully
> we'll see soon :)
> I'll report

That would be fantastic, thanks.  What test-case are you using?

Any partial information ("xxxx good, xxxx bad") would also be useful.

--b.
