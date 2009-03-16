From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 3/3] knfsd: add file to export stats about nfsd pools
Date: Mon, 16 Mar 2009 09:37:31 -0400
Message-ID: <20090316133731.GA8598@fieldses.org>
References: <20090113102633.719563000@sgi.com> <20090113102653.884405000@sgi.com> <20090212171106.GB21445@fieldses.org> <499CFF69.3000708@sgi.com> <20090315212534.GC27568@fieldses.org> <49BDC59E.9040406@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:39000 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548AbZCPNhd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2009 09:37:33 -0400
In-Reply-To: <49BDC59E.9040406@sgi.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2009 at 02:21:02PM +1100, Greg Banks wrote:
> J. Bruce Fields wrote:
> > On Thu, Feb 19, 2009 at 05:42:49PM +1100, Greg Banks wrote:
> >   
> >> J. Bruce Fields wrote:
> >>     
> >>> On Tue, Jan 13, 2009 at 09:26:36PM +1100, Greg Banks wrote:
> >>>   
> >>>       
> >>> As you said, an important question for the sysadmin is "should I
> >>> configure more nfsds?"  How do they answer that?
> >>>   
> >>>       
> >> You can work that out, [...]
> >>     
> >
> > OK, thanks, that makes sense, but: it would be really fantastic if we
> > could update and/or replace some of the howto's and faq's that are out
> > there.  
> 
> Fair enough.
> 
> After I composed the above reply, I wondered whether the right thing to
> do would have been to add that text to a new file somewhere in
> Documentation/.  Would that suit as an interim measure while I look at
> howtos and faqs?

Yep, I think that's a great idea.

> I mention this because I'll be adding more new stats
> in the next tranche of patches.

OK!--b.
