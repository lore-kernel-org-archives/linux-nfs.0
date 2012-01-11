Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47092 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755954Ab2AKOLs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 09:11:48 -0500
Date: Wed, 11 Jan 2012 09:11:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@tonian.com>, lsf-pc@lists.linux-foundation.org,
        linux-fsdevel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] linux-pnfs server implementations
Message-ID: <20120111141145.GA32230@fieldses.org>
References: <4EF6A6CA.1020606@tonian.com>
 <4F0AE25C.5020706@panasas.com>
 <20120109192517.GB16973@fieldses.org>
 <CAEMWVhvaNOENPC2jRMB7zuP4ScsNmp5BMfXYmnFL71_N-4D0Rw@mail.gmail.com>
 <4F0D8E95.60706@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F0D8E95.60706@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 11, 2012 at 03:28:53PM +0200, Boaz Harrosh wrote:
> On 01/11/2012 09:44 AM, Benny Halevy wrote:
> >>
> >> Understood that it may depend on where things stand in April, but: what
> >> specifically do you think will be likely to require the attention of a
> >> wider group of linux filesystem developers (ass opposed to just nfs
> >> developers)?
> > 
> > I have nothing specific at this time. My thinking was to present the
> > what's and why's
> > of the prerequisites in high level and maybe provide an example.
> > 
> 
> At the time there where some reservations from people about some of the
> added hooks and vectors. If there are still, we would like to hear them
> and either address them or argue their validity.

OK.

> I think this talk should be expanded with Jeff's suggestions. here:
> > - RichACLs
> > - Share/Deny mode support on open
> > - mandatory locking that doesn't rely on weirdo file modes
...
> So the broader topic can be:
> 	"The things we want/need from the Kernel to make it exportable"

Agreed that no matter where we are there will likely be a long list of
thorny questions of that sort....

--b.
