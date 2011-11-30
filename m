Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:14151 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1K3A64 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 19:58:56 -0500
Message-ID: <1322614718.11286.104.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/4] nfs41: allow layoutget at pnfs_do_multiple_writes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org,
        bhalevy@tonian.com, Garth Gibson <garth@panasas.com>,
        Matt Benjamin <matt@linuxbox.com>, Marc Eshel <eshel@almaden.ibm.com>,
        Fred Isaman <iisaman@netapp.com>
Date: Tue, 29 Nov 2011 19:58:38 -0500
In-Reply-To: <4ED577AE.2060209@panasas.com>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
	    <4ED54FE4.9050008@panasas.com> <4ED55399.4060707@panasas.com>
	   <1322603848.11286.7.camel@lade.trondhjem.org> <4ED55F78.205@panasas.com>
	  <1322606842.11286.33.camel@lade.trondhjem.org>
	  <4ED563AC.5040501@panasas.com>
	 <1322609431.11286.56.camel@lade.trondhjem.org>
	 <4ED577AE.2060209@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2011-11-29 at 16:24 -0800, Boaz Harrosh wrote: 
> On 11/29/2011 03:30 PM, Trond Myklebust wrote:
> > On Tue, 2011-11-29 at 14:58 -0800, Boaz Harrosh wrote: 
> >>
> >> The kind of typologies I'm talking about a single layout get ever 1GB is
> >> marginal to the gain I get in deploying 100 of DSs. I have thousands of
> >> DSs I want to spread the load evenly. I'm limited by the size of the layout
> >> (Device info in the case of files) So I'm limited by the number of DSs I can
> >> have in a layout. For large files these few devices become an hot spot all
> >> the while the rest of the cluster is idle.
> > 
> > I call "bullshit" on that whole argument...
> > 
> > You've done sod all so far to address the problem of a client managing
> 
> sod? I don't know this word?

'sod all' == 'nothing'

it's an English slang...

> > layout segments for a '1000 DS' case. Are you expecting that all pNFS
> > object servers out there are going to do that for you? How do I assume
> > that a generic pNFS files server is going to do the same? As far as I
> > know, the spec is completely moot on the whole subject.
> > 
> 
> What? The all segments thing is in the Generic part of the spec and is not
> at all specific or even specified in the objects and blocks RFCs.

..and it doesn't say _anything_ about how a client is supposed to manage
them in order to maximise efficiency.

> There is no layout in the spec, there are only layout_segments. Actually
> what we call layout_segments, in the spec, it is simply called a layout.
> 
> The client asks for a layout (segment) and gets one. An ~0 length one
> is just a special case. Without layout_get (segment) there is no optional
> pnfs support.
> 
> So we are reading two different specs because to me it clearly says
> layout - which is a segment.
> 
> Because the way I read it the pNFS is optional in 4.1. But if I'm a
> pNFS client I need to expect layouts (segments)
> 
> > IOW: I'm not even remotely interested in your "everyday problems" if
> > there are no "everyday solutions" that actually fit the generic can of
> > spec worms that the pNFS layout segments open.
> 
> That I don't understand. What "spec worms that the pNFS layout segments open"
> Are you seeing. Because it works pretty simple for me. And I don't see the
> big difference for files. One thing I learned for the past is that when you
> have concerns I should understand them and start to address them. Because
> your insights are usually on the Money. If you are concerned then there is
> something I should fix.

I'm saying that if I need to manage layouts that deal with >1000 DSes,
then I presumably need a strategy for ensuring that I return/forget
segments that are no longer needed, and I need a strategy for ensuring
that I always hold the segments that I do need; otherwise, I could just
ask for a full-file layout and deal with the 1000 DSes (which is what we
do today)...

My problem is that the spec certainly doesn't give me any guidance as to
such a strategy, and I haven't seen anybody else step up to the plate.
In fact, I strongly suspect that such a strategy is going to be very
application specific.

IOW: I don't accept that a layout-segment based solution is useful
without some form of strategy for telling me which segments to keep and
which to throw out when I start hitting client resource limits. I also
haven't seen any strategy out there for setting loga_length (as opposed
to loga_minlength) in the LAYOUTGET requests: as far as I know that is
going to be heavily application-dependent in the 1000-DS world.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

