Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751704AbbIRTHL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Sep 2015 15:07:11 -0400
Date: Fri, 18 Sep 2015 15:07:09 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Jeff Layton <jlayton@poochiereds.net>
cc: bfields@fieldses.org, Anna Schumaker <Anna.Schumaker@netapp.com>,
        Andrew W Elble <aweits@rit.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/2] nfsd: fix unhashing races in nfsv4 stateid
 handling
In-Reply-To: <alpine.OSX.2.19.9992.1509181504300.4198@planck.local>
Message-ID: <alpine.OSX.2.19.9992.1509181506080.4198@planck.local>
References: <1440255137-10642-1-git-send-email-jeff.layton@primarydata.com> <alpine.OSX.2.19.9992.1509181504300.4198@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 18 Sep 2015, Benjamin Coddington wrote:

> ACK to these two.  Sorry for the delay..
>
> Ben

Whoops!  Wrong posting, please disregard.  Sorry about the noise.

Not that this work is un-ackable.  Excellent work, this.  Thanks for fixing
this Jeff.

Ben

>
> On Sat, 22 Aug 2015, Jeff Layton wrote:
>
> > I hadn't heard from Andrew in a while so I'm not 100% clear on whether
> > his patches had fixed the race that he had spotted in the NFSv4
> > unhashing code.
> >
> > Still, once he had done the analysis, the problem was clear. I think
> > this patchset should fix the problem in a relatively clean way. I've
> > run some tests against this and it seems to not have broken anything,
> > but I haven't been able to reproduce the actual race so I can't
> > verify that this fixes it.
> >
> > Andrew, Anna, if you are able to do so could you test these patches
> > and let us know whether this fixes those races?
> >
> > Jeff Layton (2):
> >   nfsd: ensure that the ol stateid hash reference is only put once
> >   nfsd: ensure that delegation stateid hash references are only put once
> >
> >  fs/nfsd/nfs4state.c | 76 ++++++++++++++++++++++++++++++++++-------------------
> >  1 file changed, 49 insertions(+), 27 deletions(-)
> >
> > --
> > 2.4.3
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
