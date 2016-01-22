Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49223 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750962AbcAVPYa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2016 10:24:30 -0500
Date: Fri, 22 Jan 2016 10:24:29 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, dros@primarydata.com
Subject: Re: [PATCH v2 3/3] nfsd: implement machine credential support for
 some operations
Message-ID: <20160122152429.GA9082@fieldses.org>
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
 <1453147702-42961-4-git-send-email-aweits@rit.edu>
 <20160121190134.GB1793@fieldses.org>
 <m237tqpw65.fsf@discipline.rit.edu>
 <20160121195003.GD1793@fieldses.org>
 <m2si1qmqhw.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2si1qmqhw.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 21, 2016 at 07:01:31PM -0500, Andrew W Elble wrote:
> 
> > Ugh.  So the client actually needs to allow random other ops in any
> > compound containing an spo_must_allow'd operation?  That doesn't seem
> > right to me.
> 
> Well, that's most certainly my fault. Seems like I should
> submit a patch to have the client ask for GETATTR if it's going to send
> it as a tag-along to DELEGRETURN. Is WRONGSEC really the correct way
> to enforce appropriate use of spo_must_allow here?
> 
> For instance, the client could ask for just DELEGRETURN:
> 
> PUTFH
> GETATTR
> DELEGRETURN
> 
> ...would be successful as long as the export was done with krb5i/krb5p.

I don't know what the right thing to do is here.

I wonder what the GETATTR's for?  I guess if any changes are flushed
before sending this compound then this is a good chance to get a
changeattr for a known state.  For that you need the GETATTR to be
sequenced before the DELEGRETURN, so that it happens before any other
clients start writing, and the only other way to do that is to send the
GETATTR separately and wait for the response.  Which would be annoying.

You could add GETATTR to must_allow.  But then the GETATTR could in
theory be denied.  I think that would only happen in the case of servers
that enforce ACE4_READ_ATTRIBUTES.  I seem to recall seeing such at
testing events, but maybe they're rare.  I guess you could handle that
rare case by resending the DELEGRETURN without the GETATTR.  Also kind
of annoying.

--b.
