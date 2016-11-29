Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-banded.atl.sa.earthlink.net ([209.86.89.70]:37149 "EHLO
        elasmtp-banded.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751726AbcK2Xv5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2016 18:51:57 -0500
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'J. Bruce Fields'" <bfields@redhat.com>,
        "'Tom Haynes'" <loghyr@primarydata.com>
Cc: "'Linux NFS Mailing list'" <linux-nfs@vger.kernel.org>
References: <1480228001-64821-1-git-send-email-loghyr@primarydata.com> <20161128163321.GB30805@parsley.fieldses.org>
In-Reply-To: <20161128163321.GB30805@parsley.fieldses.org>
Subject: RE: [PATCH pynfs 00/12] Flex File support
Date: Tue, 29 Nov 2016 15:44:48 -0800
Message-ID: <012c01d24a9a$92ff7580$b8fe6080$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Monday, November 28, 2016 8:33 AM
> To: Tom Haynes <loghyr@primarydata.com>
> Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
> Subject: Re: [PATCH pynfs 00/12] Flex File support
> 
> On Sat, Nov 26, 2016 at 10:26:29PM -0800, Tom Haynes wrote:
> > I wanted to add client support for the flex file layout.
> >
> > Note, I did not add pynfs as a flag because I didn't want to mess up
> > with any existing uses of it.
> >
> > The other major change here is in closing all opened files and
> > destroying all clientids. With all the tests which run against my
> > server, there are no longer any open files. There are however 11
> > clientids remaining.
> >
> > I will track those down.
> >
> > fwiw - these are in my staging branch at
> > git://linux-nfs.org/~loghyr/pynfs.git
> 
> Thanks!  I'll try these and take a look.
> 
> How did you notice all the leftover state?  I run with a pretty short
lease time
> (to speed testing), so I guess the leftover state must expire too quickly
to
> cause me problems.
> 
> Anyway it's good to have that cleaned up.

Not closing files and releasing clientids at least in the 4.0 tests has
actually shaken out bugs in Ganesha...

But maybe that kind of thing should be an explicit test, create lots of
clientids/sessions, and then wait for them all to expire and see if the
server can handle all the activity.

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

