Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58181 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934180Ab3BTP7k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Feb 2013 10:59:40 -0500
Date: Wed, 20 Feb 2013 10:59:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linux NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 00/14] lnfs: 3.8-rc7 release
Message-ID: <20130220155933.GI14606@fieldses.org>
References: <1361213276-17962-1-git-send-email-SteveD@redhat.com>
 <20130218195834.GA3391@fieldses.org>
 <512395D7.5010205@RedHat.com>
 <20130219151808.GE3391@fieldses.org>
 <51239CFF.9000600@RedHat.com>
 <20130219205608.GB14606@fieldses.org>
 <5124F1EA.2090902@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5124F1EA.2090902@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 20, 2013 at 10:55:22AM -0500, Steve Dickson wrote:
> Trimming the cc list to just Linux NFS list since I'm
> sure they will not care about this part of the discussion.
> I'll add them back on my next release...   
> 
> On 19/02/13 15:56, J. Bruce Fields wrote:
> > On Tue, Feb 19, 2013 at 10:40:47AM -0500, Steve Dickson wrote:
> >> On 19/02/13 10:18, J. Bruce Fields wrote:
> >>> On Tue, Feb 19, 2013 at 10:10:15AM -0500, Steve Dickson wrote:
> >>>>
> >>>>
> >>>> On 18/02/13 14:58, J. Bruce Fields wrote:
> >>>>> On Mon, Feb 18, 2013 at 01:47:42PM -0500, Steve Dickson wrote:
> >>>>>>> From: Steve Dickson <steved@redhat.com>
> >>>>>>>
> >>>>>>> Here is the next release of the Label NFS patches, forward 
> >>>>>>> ported to linux-3.8-rc7
> >>>>>>>
> >>>>>>> I believe I've  incorporated all code review that were made
> >>>>>>> from the last release,
> >>>>> Except I think this doesn't turn on minor version 2?
> >>>> Are you saying we need a -o v4.2 mount option to enable this feature?
> >>> Yes.  And the client needs to send requests with minor version 2, and
> >>> server needs to accept such requests.
> >> Boy this puts a damper on the party.... ;-)
> > 
> > I'm hoping it's not that much work: we already have two minor versions
> > (0 and 1), in theory adding a third should be pretty straightforward.
> > 
> > Labeled NFS will be our only 4.2 feature for now, so there's nothing
> > else to do other than turn on support for the new minor version number.
> > 
> > I think so?
> On the client the actual change is very straightforward. Simply added
> another case to the switch in  nfs_parse_version_string() and set the
> minorversion to 2
> 
>     case Opt_vers_4_2:
>         mnt->version = 4;
>         mnt->minorversion = 2;
>         break;
> 
> But my question is what type of ramification well there be bumping 
> minorversion from 1 to 2?  I bet servers are not going to like this
> too much... ;-)

If they support labeld NFS, they have to support minor version 2.

> and not to mention all the xdr and callback routines
> that look at minorversion... a bit worrisome...
>
> Speaking of servers... Do you think its about time to rpc.nfsd the
> ability to enable 4.x versions?

	echo "+4.2" >/proc/fs/nfsd/versions

--b.
