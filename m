Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:54579 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752630Ab3EMRhZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 13:37:25 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: RE: 3.11 patches
Date: Mon, 13 May 2013 17:37:17 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA928778002@SACEXCMBX04-PRD.hq.netapp.com>
References: <20130513152312.GB1931@fieldses.org>
 <1368458889.3563.7.camel@leira.trondhjem.org> <51912356.4080100@RedHat.com>
In-Reply-To: <51912356.4080100@RedHat.com>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: Steve Dickson [mailto:SteveD@redhat.com]
> Sent: Monday, May 13, 2013 1:31 PM
> To: Myklebust, Trond
> Cc: J. Bruce Fields; linux-nfs@vger.kernel.org
> Subject: Re: 3.11 patches
> 
> 
> 
> On 13/05/13 11:28, Myklebust, Trond wrote:
> > On Mon, 2013-05-13 at 11:23 -0400, J. Bruce Fields wrote:
> >> I've added a labeled-nfs-common branch at
> >>
> >> 	git://linux-nfs.org/~bfields/linux.git labeled-nfs-common
> >>
> >> with 3.10-rc1 + the one labeled NFS patch shared by client and server
> >> (with just some protocol constants).
> >>
> >> So we can all work on top of that if we want.
> >
> > OK. I've pushed out a 'labeled-nfs' branch for the client side that is
> > based upon the above branch.
> Momentary I will be posting the  3.10-rc1 forward port.
> 
> >
> > Has James added the security patches to a public branch that we can
> > pull yet?
> >
> No and he does not plan to... because "It won't be functional without the
> security subsystem patches, so they should all be in his tree." Meaning your
> tree...

As long as James is fine with me pushing those patches, then I'm happy to do so...

Cheers
  Trond
