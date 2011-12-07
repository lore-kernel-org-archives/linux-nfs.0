Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e32.co.us.ibm.com ([32.97.110.150]:49702 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756042Ab1LGPMy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2011 10:12:54 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <ffilz@us.ibm.com>;
	Wed, 7 Dec 2011 08:12:54 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB7FCexg088924
	for <linux-nfs@vger.kernel.org>; Wed, 7 Dec 2011 08:12:46 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB7FCYAW031951
	for <linux-nfs@vger.kernel.org>; Wed, 7 Dec 2011 08:12:36 -0700
In-Reply-To: <4EDF6A1E.6020400@cea.fr>
References: <4EDCCC89.6080205@cea.fr>	<1323128020.7237.3.camel@lade.trondhjem.org>	<4EDE0659.3060508@cea.fr> <20111206193747.GA11788@fieldses.org> <4EDF6A1E.6020400@cea.fr>
Subject: Re: [Nfs-ganesha-devel] Help wanted: ENOCLK returned during lock test#2 in
 connectathon's test
To: DENIEL Philippe <philippe.deniel@cea.fr>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-ID: <OF46F43651.D8FC4C84-ON8725795F.005303EE-8825795F.00538A27@us.ibm.com>
From: Frank S Filz <ffilz@us.ibm.com>
Date: Wed, 7 Dec 2011 07:12:28 -0800
MIME-Version: 1.0
Content-type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

DENIEL Philippe <philippe.deniel@cea.fr> wrote on 12/07/2011 05:29:02 AM:
> Hi Bruce,
>
> Yes I am talking about the seqid inside the stateid.

The seqid inside the stateid also should be an unlikely place for a
difference between NFS v4 and NFS v4.1 since NFS v4.1 still has the seqid
inside the stateid. See  9.4. Stateid Seqid Values and Byte-Range Locks for
locks (p. 189 of rfc5661). See   9.9. Open Upgrade and Downgrade on p. 192
for open.

Frank

> J. Bruce Fields a écrit :
> > On Tue, Dec 06, 2011 at 01:11:05PM +0100, DENIEL Philippe wrote:
> >
> >> Hi Trond,
> >>
> >> many thanks for your reply.
> >> In fact, the "rflag" in OP4_OPEN's reply is set to 6 = 4|2 =
> >> OPEN4_RESULT_LOCKTYPE_POSIX|OPEN4_RESULT_CONFIRM
> >> For some reason I do not understand, wireshark see
> >> OPEN4_RESULT_LOCKTYPE_POSIX as an 'unknown' flag and do not print
> >> it.  Bug actually it seems like OPEN4_RESULT_LOCKTYPE_POSIX is set.
> >>
> >> Your mail made me have a closer look to my implementation of
> >> OP4_OPEN and OP4_OPEN_CONFIRM in NFSv4.0 . Since the beginning
> >> (since I met this bug), I suspect something related to seqids : it
> >> does not occur in NFSv4.1 where seqids 's management is made in
> >> OP4_SEQUENCE, at the beginning of the request. So I ran lock test#2
> >> on a kernel nfsd, capture the result and compared to what ganesha
> >> produces. I saw a difference:
> >> - when OP4_OPEN is invoked, the nfsd replies with a stateid
> >> containing seqid=0. This seqid is passed to OP4_OPEN_CONFIRM which
> >> confirms it and (if OK) replies with an updated stateid (seqid is
> >> now 1)
> >> - when ganesha does the same OP4_OPEN return a (unconfirmed) stateid
> >> whose seqid is equal to 1, then OP4_OPEN_CONFIRM set this seqid to 2
> >> when confirming the stateid.
> >>
> >
> > Sounds like you're talking about the seqid field that's contained in
the
> > stateid itself--I'd be suprised if the client cares about it.  The spec
> > does allow the client to inspect that field to decide what order opens
> > were done in, but other than that a client normally treats the whole
> > stateid as opaque.
> >
> > --b.
> >
> >
> >> From your point of view, could this mess in seqid's management
> >> produce the bug that I see when running lock test#2 ?
> >>
> >>    Regards
> >>
> >>       Philippe
> >>
> >> Trond Myklebust a écrit :
> >>
> >>> On Mon, 2011-12-05 at 14:52 +0100, DENIEL Philippe wrote:
> >>>
> >>>> Hi,
> >>>>
> >>>> as you may know (we may have met at Bake-A-Thon), I am working
> >>>> on NFS-Ganesha, a NFS server running in userspace. I currently
> >>>> face an issue when running cthon04 test suite, during the "lock
> >>>> step".
> >>>> Client is linux 3.1.0-rc4, server is nfs-ganesha compiled with
> >>>> FSAL_VFS support. Server is mounted via command "mount
> >>>> -overs=4.minorversion=1,lock <server>:<path> /mnt"
> >>>>
> >>>> During the test#2 in "lock" tests, I got the following error:
> >>>>
> >>>>    Creating parent/child synchronization pipes.
> >>>>
> >>>>    Test #2 - Try to lock the whole file.
> >>>>            Parent: 2.0  - F_TLOCK [               0,
ENDING]
> >>>>    FAILED!
> >>>>            Parent: **** Expected success, returned errno=37...
> >>>>            Parent: **** Probably implementation error.
> >>>>
> >>>>    ** PARENT pass 1 results: 0/0 pass, 0/0 warn, 1/1 fail
(pass/total).
> >>>>
> >>>>    **  CHILD pass 1 results: 0/0 pass, 0/0 warn, 0/0 fail
(pass/total).
> >>>>
> >>>>
> >>>> I made a wireshark capture of the packet (see attachement).
> >>>> Apparently, the client does 2 compounds, one for OP4_OPEN and a
> >>>> second to call OP4_OPEN_CONFIRM.
> >>>>
> >>> Hi Philippe,
> >>>
> >>> As far as I can see from the pcap file, your server isn't setting the
> >>> OPEN4_RESULT_LOCKTYPE_POSIX flag in the OPEN reply, and so the client
> >>> can't support posix locking semantics. In that case, it will return
> >>> ENOLCK to all fcntl locking requests.
> >>>
> >>> Cheers
> >>>  Trond
> >>>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
>
>
>
------------------------------------------------------------------------------

> Cloud Services Checklist: Pricing and Packaging Optimization
> This white paper is intended to serve as a reference, checklist and point
of
> discussion for anyone considering optimizing the pricing and packaging
model
> of a cloud services business. Read Now!
> http://www.accelacomm.com/jaw/sfnl/114/51491232/
> _______________________________________________
> Nfs-ganesha-devel mailing list
> Nfs-ganesha-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs-ganesha-devel

