Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:37176 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753169Ab1HDBOG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 21:14:06 -0400
Date: Thu, 4 Aug 2011 11:13:57 +1000
From: NeilBrown <neilb@suse.de>
To: Kevin Coffman <kwc@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems with kerberos auth - possibly against ADS - since
 nfs-utils-1.2.3
Message-ID: <20110804111357.0d0a6e85@notabene.brown>
In-Reply-To: <CAKnQG+cs4SLD-YmLwpnXU_gDWrjfmx9+z-E=7J-SUcsP=KhfSg@mail.gmail.com>
References: <20110804092141.3461c9ce@notabene.brown>
	<CAKnQG+cs4SLD-YmLwpnXU_gDWrjfmx9+z-E=7J-SUcsP=KhfSg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 3 Aug 2011 20:51:52 -0400 Kevin Coffman <kwc@umich.edu> wrote:

> On Wed, Aug 3, 2011 at 7:21 PM, NeilBrown <neilb@suse.de> wrote:
> >
> > Hi,
> >  I have some reports of problems with kerberos auth in openSUSE 11.4 (using
> >  1.2.3) which can be fixed by using the openSUSE 11.3 version of rpc.gssd
> >  (from 1.2.1).
> >
> > https://bugzilla.novell.com/show_bug.cgi?id=614293
> >
> >  The important difference seems to be the list of enc_types used in
> >  limit_krb5_enctypes.
> >
> >  In 1.2.1 this list is hard coded in the rpc.gssd to 1,3,2 (I think).
> >  In 1.2.3 this list is taken from the kernel where is it hard coded
> >  to  18,17,16,23,3,1,2.
> >  When I patch the 11.4 code to use the old enctype list, it works perfectly.
> >
> >  So presumably it ends up negotiating one of those other enc_types and
> >  gets confused by it.
> >
> >  I'll try to get a comparative tcp dump to see if that helps, but
> >  if anyone has any idea what the problem might be I'd love to hear
> >  suggestions.
> >
> >  The systems are running a 2.6.37 kernel in case that might make a difference.
> >
> > Thanks,
> > NeilBrown
> 
> Hi Niel,
> Seeing the traffic might help.  It wasn't clear to me after reading
> (most of) the bugzilla info what kernel version the NFS servers
> involved are running.  If the servers don't have kernels with the
> newer enctype support, this might be the "subkey assertion" issue.
> 

Hi Kevin,
 thanks for the reply.  I've asked for that extra info (trace and server
 details) - hopefully we'll get that in the next day or so.

 The this is a buggy server issue, and it is wide-spread, I wonder if it
 might make sense for gssd to fall back on the old enctype list if
 negotiation fails with the new list.  Does that sound at all reasonable?

Thanks,
NeilBrown
