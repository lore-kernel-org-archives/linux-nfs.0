Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49265 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754204AbcAVQgV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Jan 2016 11:36:21 -0500
Date: Fri, 22 Jan 2016 11:36:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, dros@primarydata.com
Subject: Re: [PATCH v2 3/3] nfsd: implement machine credential support for
 some operations
Message-ID: <20160122163620.GD9082@fieldses.org>
References: <1453147702-42961-1-git-send-email-aweits@rit.edu>
 <1453147702-42961-4-git-send-email-aweits@rit.edu>
 <20160122154045.GB9082@fieldses.org>
 <m27fj1lhp0.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m27fj1lhp0.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 22, 2016 at 11:09:15AM -0500, Andrew W Elble wrote:
> 
> > By the way, is the only problem is that the client is trying to do
> > krb5i/krb5p on an export exported only with sec=sys or sec=krb5?
> 
> Barring anything else I missed, yes.
> 
> > So for example we could allow krb5i/krb5p on any compound containing an
> > so_must_allow op?
> 
> This was roughly my reasoning/question...

Right, so I guess I've convinced myself to stop worrying as much about
whether your nfsd4_spo_must_allow allows too much.

In fact I wonder if it'd be simpler just to skip the OP_IS_PUTFH_LIKE
checks and just set spo_must_allowed on any compound with any must_allow
op in it.

At worst we've allowed use of krb5p/krb5i for a few ops on filesystems
that don't allow those, but who cares.

It doesn't bypass filesystem permission checks on operations that do
permission checks, and you still might consider removing that fh_verify
from DELEGRETURN in a separate patch.  And the client may still have
some trouble with filesystems that do permission checks on GETATTR.

--b.
