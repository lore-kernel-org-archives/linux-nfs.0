Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46655 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431Ab3H2NaU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Aug 2013 09:30:20 -0400
Date: Thu, 29 Aug 2013 09:30:10 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: richard -rw- weinberger <richard.weinberger@gmail.com>
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "user-mode-linux-devel@lists.sourceforge.net"
	<user-mode-linux-devel@lists.sourceforge.net>,
        Linux Kernel <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>,
        linux-ext4@vger.kernel.org
Subject: Re: [uml-devel] Issues with a rather unusual configured NFS server
Message-ID: <20130829133010.GA14773@fieldses.org>
References: <52075E01.7030506@gmx.de>
 <20130812143640.GF4596@quack.suse.cz>
 <20130813215313.GH17781@fieldses.org>
 <20130827180655.GE14809@fieldses.org>
 <521E318C.7040401@gmx.de>
 <CAFLxGvyK5+nB9TgW1uPho9KGwQrWQHx=wEpj+o-mZcN92bWAOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CAFLxGvyK5+nB9TgW1uPho9KGwQrWQHx=wEpj+o-mZcN92bWAOg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 29, 2013 at 11:57:45AM +0200, richard -rw- weinberger wrote:
> On Wed, Aug 28, 2013 at 7:21 PM, Toralf Förster <toralf.foerster@gmx.de> wrote:
> > On 08/27/2013 08:06 PM, J. Bruce Fields wrote:
> >> On Tue, Aug 13, 2013 at 05:53:14PM -0400, bfields wrote:
> >>> On Mon, Aug 12, 2013 at 04:36:40PM +0200, Jan Kara wrote:
> >>>> On Sun 11-08-13 11:48:49, Toralf Förster wrote:
> >>>>> so that the server either crashes (if it is a user mode linux image) or at least its reboot functionality got broken
> >>>>> - if the NFS server is hammered with scary NFS calls using a fuzzy tool running at a remote NFS client under a non-privileged user id.
> >>>>>
> >>>>> It can re reproduced, if
> >>>>>    - the NFS share is an EXT3 or EXT4 directory
> >>>>>    - and it is created at file located at tempfs and mounted via loop device
> >>>>>    - and the NFS server is forced to umount the NFS share
> >>>>>    - and the server forced to restart the NSF service afterwards
> >>>>>    - and trinity is used
> >>>>>
> >>>>> I could find a scenario for an automated bisect. 2 times it brought this commit
> >>>>> commit 68a3396178e6688ad7367202cdf0af8ed03c8727
> >>>>> Author: J. Bruce Fields <bfields@redhat.com>
> >>>>> Date:   Thu Mar 21 11:21:50 2013 -0400
> >>>>>
> >>>>>     nfsd4: shut down more of delegation earlier
> >>>
> >>> Thanks for the report.  I think I see the problem--after this commit
> >>> nfs4_set_delegation() failures result in nfs4_put_delegation being
> >>> called, but nfs4_put_delegation doesn't free the nfs4_file that has
> >>> already been set by alloc_init_deleg().
> >>>
> >>> Let me think about how to fix that....
> >>
> >> Sorry for the slow response--can you check whether this fixes the
> >> problem?
> >>
> > Yes.
> >
> > With the attached patch the problem can't be reproduced any longer with
> > the prepared test case and current git kernels.
> 
> BTW: Is nobody else fuzz testing NFS?

I don't know.  Toralf's reports are the only ones I recall off the top
of my head, but I may have forgotten others.

> Or are these bugs just more likely to hit on UML?

That's also possible.

> This is not the first NFS issue found by Toralf using UML and Trinity.

Yep.  The testing is definitely appreciated.

--b.
