From: "NeilBrown" <neilb@suse.de>
Subject: Re: nfs-utils 1.1.2 + knfsd 2.6.27 (.5) breaks fsid= option
Date: Mon, 17 Nov 2008 11:52:05 +1100 (EST)
Message-ID: <ddb3d04e3a8e7d898b42e122555ddb44.squirrel@neil.brown.name>
References: <20081112104811.GA15011@janus> <491ADEBF.80900@RedHat.com>
    <20081116200211.GK21551@fieldses.org>
    <20081116215700.GB25834@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Steve Dickson" <steved@redhat.com>,
	"Frank van Maarseveen" <frankvm@frankvm.com>,
	"Linux NFS mailing list" <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:37525 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751966AbYKQAwN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 16 Nov 2008 19:52:13 -0500
In-Reply-To: <20081116215700.GB25834@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, November 17, 2008 8:57 am, J. Bruce Fields wrote:
> On Sun, Nov 16, 2008 at 03:02:11PM -0500, bfields wrote:
>> On Wed, Nov 12, 2008 at 08:48:47AM -0500, Steve Dickson wrote:
>> > Frank van Maarseveen wrote:
>> > > Tested on Debian lenny with nfs-kernel-server 1:1.1.2-6lenny1 and a
>> > > 2.6.27.5 kernel. /etc/exports says:
>> > >
>> > > 	/mp
>> @general(rw,sync,no_root_squash,no_subtree_check,mp,fsid=2886795869)
>> > >
>> > > After actually using it /proc/fs/nfsd/exports says:
>> > >
>> > > 	/mp
>> @general(rw,no_root_squash,sync,wdelay,no_subtree_check,fsid=-1408171427,uuid=db4387a6:bed949d0:8f5ef6a2:6a0c
>> > >
>> > > (yes, 2886795869 == (ulong)-1408171427)
>> > > However, file handles over the wire now seem to have fsid_type=6
>> > > (FSID_UUID16) instead of 1 (FSID_NUM) due to this.
>> >
>> > This is a known problem... The kernel checks UUIDs before FSIDS which
>> cause
>> > FSIDS to be ignored. There are two outstanding proposals to fix this
>> problem.
>> >    1) Move two lines in the kernel so FSIDs are checked before UUIDS
>> >    2) Change mountd to only send down  the FSID or the UUID but
>> >       not both as it does today.
>> >
>> > Neither proposal has been accepted... yet...
>>
>> I'd have a mild preference for the 2nd,
>
> Maybe I should take that back--Neil, don't we need to pass down the uuid
> to match the client-provided filehandle type in the case where they're
> giving us uuid-style filehandles?  In that case we need to pass down
> both so the kernel can choose the desired one.  So if we need to fix
> this then that would make SteveD's patch the way to go.

Yes, I seem to be leaning towards option 1 now as well.
We probably never should have given UUIDs to the kernel if an fsid was
given (unless a uuid was given too).  In that case we wouldn't have
an issue here.
But as we do, the law of least surprise suggests that when an fsid is
explicitly given, it should be preferred.

So yeah, let's go with Steve's proposal.

NeilBrown

