Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48709 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485AbcAUTuE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2016 14:50:04 -0500
Date: Thu, 21 Jan 2016 14:50:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, dros@primarydata.com
Subject: Re: [PATCH v2 3/3] nfsd: implement machine credential support for
 some operations
Message-ID: <20160121195003.GD1793@fieldses.org>
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
 <1453147702-42961-4-git-send-email-aweits@rit.edu>
 <20160121190134.GB1793@fieldses.org>
 <m237tqpw65.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m237tqpw65.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 21, 2016 at 02:30:42PM -0500, Andrew W Elble wrote:
> 
> > Doesn't this mean that a compound like e.g.:
> >
> > 	PUTFH
> > 	CLOSE
> > 	OPEN
> >
> > would result in a return of true on the OPEN, if CLOSE was in must_allow
> > but OPEN wasn't?  (Because the above loop sets spo_must_allowed as soon
> > as it hits the CLOSE.)
> 
> Yes. A real-world example is DELEGRETURN with the Linux NFS client:
> 
> PUTFH
> GETATTR
> DELEGRETURN
> 
> GETATTR isn't in spo_must_allowed, but the whole compound request looks like
> krb5i in a krb5 setting. Still digesting the rest of your replies...

Ugh.  So the client actually needs to allow random other ops in any
compound containing an spo_must_allow'd operation?  That doesn't seem
right to me.

--b.
