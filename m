Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71282C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 13:10:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 367AA2146E
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 13:10:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549631459;
	bh=bxr9GplJqacIKYNE99kQ8gLDjB3J/DmtXJi8IazYSI0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:List-ID:From;
	b=CohBIphQCL2L0+gLFUq90pMKs/B5I6F45g2lxhFwZQoZBnVKDnVOW9LjJsZa+VCYy
	 sJz+MlpArGF4oNEpqeY+a66uyEQ98d5U1flt3u0CnE+cUuA7zOkgmKAWx+gicfOZmB
	 CblHWccG3bOqf4VOAmpBSVXdpbW70SlXM0QtIiT0=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727489AbfBHNK6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 08:10:58 -0500
Received: from mail.kernel.org ([198.145.29.99]:57910 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726547AbfBHNK6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 08:10:58 -0500
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D3A5A20844;
        Fri,  8 Feb 2019 13:10:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1549631456;
        bh=bxr9GplJqacIKYNE99kQ8gLDjB3J/DmtXJi8IazYSI0=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=GHJibtl3jfU+EEoQneFuFnoEupyUEMkcBcmAtk3Ty2x+wg71pvhEKQWkaBCgKw7EZ
         RoV1TJrJ3Son6CjDBgxqb7DNutPPWR9ni1vShDIDgl/lNHgTnA2fyASY0Fk1NYUWDn
         fZUB5chkEFQ3O24HfGvPGkYqgeE8EWaEDfFL4jkM=
Message-ID: <379106947f859bdf5db4c6f9c4ab8c44f7423c08.camel@kernel.org>
Subject: Re: Better interop for NFS/SMB file share mode/reservation
From:   Jeff Layton <jlayton@kernel.org>
To:     Amir Goldstein <amir73il@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc:     Volker.Lendecke@sernet.de, samba-technical@lists.samba.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Pavel Shilovsky <piastryyy@gmail.com>
Date:   Fri, 08 Feb 2019 08:10:54 -0500
In-Reply-To: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
References: <CAOQ4uxjQdLrZXkpP30Pq_=Cckcb=mADrEwQUXmsG92r-gn2y5w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2019-02-08 at 13:20 +0200, Amir Goldstein wrote:
> Hi Bruce,
> 
> I have been following you discussion with Volker Lendecke
> on the samba technical mailing list [1] and have had discussed
> this issue with Volker myself as well.
> 
> I decided to start this new thread to bring some kernel developers
> in the loop and to propose an idea that takes a somewhat
> different approach to the "interop" approaches I have seen
> so far. "interop" in this context often means consistency of file
> lock states between samba and nfs server, but I am referring
> to the stronger sense of interop with local filesystem on the server.
> 
> You pointed to Pavel Shilovsky's O_DENY* patches [2] as a possible
> solution to interop of NFS Share Reservation and SMB Share Mode
> with local filesystems.
> Some of the complaints on this approach were (rightfully) concerned
> about DoS and the prospect of plaguing Linux with Windows server
> "files left open" issues.
> 
> My idea comes from the observation that Windows server
> administrators can release locked files that were left open by clients.
> I suppose that an NFS server admin can do the same?

The Linux kernel has no mechanism for this (aside from sending a SIGKILL
to lockd, which makes it drop all locks). Solaris did have a tool for
this at one point (and probably still does).

It's a little less of a problem now than it used to be with NFS, given
the move to NFSv4 (which has lease-based locking). If you have
misbehaving clients, you just kick them out and their locks eventually
go away. v3 locks can stick around in perpetuity however, so people have
long wanted such a tool on Linux as well.

> That realization makes "share access" locks (a.k.a. MAND_LOCK)
> not so very different from oplocks (leases/delegations).
> As long as samba and nfsd cooperate nicely with MAND_LOCK
> semantics, we don't really have to force local filesystems
> to obay MAND_LOCK semantics. If the file servers take leases
> on local filesystems, they will not get exclusive write access for
> files already open for write on local filesytem and same for read.
> 

I think this last statement isn't correct (if I'm parsing it correctly).
If a file is already open for write, then you just don't get a lease
when you try to request one. Ditto for write leases if it's already open
for read.

> On local file access on the server that violates the share mode,
> the file server acts as a grumpy washed out administrator that
> automatically grants any lock revoke ticket after timeout.
> 

Devil's advocate:

Is this situation any better than just teaching the NFS/SMB servers to
track these locks out of band? Both samba and most NFS servers respect
share/deny mode locks, but only internally -- they aren't aware of the
others'. We could (in principle) come up with a mechanism to track these
that doesn't involve plumbing them into the kernel.

That said, coherent locking is best done in the kernel, IMO...

> This model may not fit use cases where "real" interop with
> local filesystem is needed, but compared to the existing
> solution (no interop at all) it is quite an improvement.
> 
> Furthermore, short of SMB DENY_DELETE, we may not even
> need to change any kernel APIs.
> The addition of O_DENY* open flags can make programming
> easier, but taking a lease on an open file is still safe enough
> to implement share reservation (no?).
> 
> Satisfying DENY_DELETE could be more tricky, but perhaps
> the existing SILLYRENAME interface of==between knfsd and vfs
> could be somehow utilized for this purpose?
> 
> I though of bringing this up as a TOPIC for LSF/MM, but wanted
> to consult with you first. I am sure that you or Jeff can do a better
> job than me in enumerating the "interop" file lock issues that
> could be discussed in filesystems track forum.
> 
> Thoughts? Explanation why this idea is idiotic?

I think it's not a single idea. There are really two different aspects
to this given that we're really talking about two different types of
locks in SMB. I think you have to consider solving these problems
separately:

1) the ability to set a (typically whole-file) share/deny lock
atomically when you open a file. This is necessary for coherent
share/deny lock semantics. Note that these are only enforced open()
time.

2) mandatory locking (forbidding reads and writes on a byte range when
there is a conflicting lock set).

The first could (probably) be solved with something like what Pavel
proposed a few years ago...or maybe we just wire up O_EXLOCK and
O_SHLOCK:

    https://www.gnu.org/software/libc/manual/html_node/Open_002dtime-Flags.html

This seems like a fine idea (in principle) but it needs someone to drive
the work forward. You'll also likely be consuming a couple of O_* flags,
which could be tough sell (unless you come up with another way to do
it).

The second problem is much more difficult to fix correctly, and involves
interjecting locking checks into (hot) file read/write codepaths. This
is non-trivial and could have performance impacts even when no lock is
set on a file.
-- 
Jeff Layton <jlayton@kernel.org>

