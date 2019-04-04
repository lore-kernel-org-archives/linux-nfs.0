Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D565C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:36:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C7EA32082E
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:36:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=poochiereds-net.20150623.gappssmtp.com header.i=@poochiereds-net.20150623.gappssmtp.com header.b="ZO1dw1Gt"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727191AbfDDPgj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 11:36:39 -0400
Received: from mail-ed1-f67.google.com ([209.85.208.67]:46516 "EHLO
        mail-ed1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727152AbfDDPgj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2019 11:36:39 -0400
Received: by mail-ed1-f67.google.com with SMTP id d1so2603053edd.13
        for <linux-nfs@vger.kernel.org>; Thu, 04 Apr 2019 08:36:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=poochiereds-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=STAb6LzB8FLnMAAUPPtQ94uGwE4PG3l3fdd4oBEFVzs=;
        b=ZO1dw1GtcSctb4vibMuj6cpywkZ56hCTN9F/JEq1i1ZZ01g6n1DpCChZJMDgg7pJ1y
         6LbA7i5yVIWfpZAhbc8c2GPbGTo7XVZhGcSssda8+DCcEYMJ7GNpYwvweKk0JV3KIggm
         Kj7Z5/m0CbeLPS0ajuFziNyDKdsDlUjY3rho+2M6nPu8FjC2NGk4MhRYlPq8fb/mg8j4
         c8mN55aZtG0y/z2lIHpGrG4QKnfy470VN6Ik8PNVeQPhwNO9qSv7SMfeCFPyRi6KJ1Su
         oEviRbY4l5ptcog7EFq3Yp6X+HARlaTsLM0rrlCAhpHS3tMAHw4VOS+jkawynRa/4LDW
         xvdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=STAb6LzB8FLnMAAUPPtQ94uGwE4PG3l3fdd4oBEFVzs=;
        b=pc7hjTsTyRZCPy9jEOsju2FDM9K6fMBp/9X0CCKjzid2YNhYISPxs4s/ysag/kJBSO
         UItcUGwaRw1vkFN83hzeiffTkVsF4EcelZH0bK1Rvbt33b4KZsB8nKzNih+xMUrA5qLE
         os3H7WCL4WCmHnRP9CAQoTTeu/m8lKnjmp6kb+G75dLhK3WPkcvEMlN3dND+Ytj4oPTq
         bA+qm+oDCeFtNkspq1zdIy+a+SoggGdWogBu7/bFwkL9OQi3z8lK8r4bjNo41PhnjGfi
         vAp4N3FuV5RlgOpC+7tUa32RWWYUCwGMgDpbCpYufVhw0wKCUcbuPPu8TrbhRtKqwbAa
         Dleg==
X-Gm-Message-State: APjAAAWhAgBPeIO7WTMWzx9SXSKLQ409tZsQcd+jqlgU+Y435zo/x6Cp
        wY9Xm4nAVyzSfgfdfUgmZS+U/O+oGUQE1zy3XJuocg==
X-Google-Smtp-Source: APXvYqwRlpTHKr75kvlxsmPCDFkh2egDFT3nuuZVdiagDysPsjocYrNWYqHytAwjjh259W5WYpO6qOlKIr0w17HJWfw=
X-Received: by 2002:a50:a5e5:: with SMTP id b34mr4206721edc.260.1554392196675;
 Thu, 04 Apr 2019 08:36:36 -0700 (PDT)
MIME-Version: 1.0
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org> <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
 <20190402194148.GA5269@fieldses.org> <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org> <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
 <20190403020750.GA8272@fieldses.org> <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
 <20190404010559.GA17840@fieldses.org> <CAOhYWNLZ2OmnGo2nEegmuXOrU_ncmAwWgQSAMXxKfn3JP-UMUw@mail.gmail.com>
 <97542732-49F5-4BEA-9903-D9801370A221@oracle.com>
In-Reply-To: <97542732-49F5-4BEA-9903-D9801370A221@oracle.com>
From:   Jeff Layton <jlayton@poochiereds.net>
Date:   Thu, 4 Apr 2019 11:36:25 -0400
Message-ID: <CAOhYWNJ=w2ni2aR703dhSov155UR2D-1HP3MT5D-NSoegv2bJw@mail.gmail.com>
Subject: Re: directory delegations
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Bruce Fields <bfields@fieldses.org>,
        "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Apr 4, 2019 at 11:22 AM Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>
> > On Apr 4, 2019, at 11:09 AM, Jeff Layton <jlayton@poochiereds.net> wrot=
e:
> >
> > On Wed, Apr 3, 2019 at 9:06 PM bfields@fieldses.org
> > <bfields@fieldses.org> wrote:
> >>
> >> On Wed, Apr 03, 2019 at 12:56:24PM -0400, Bradley C. Kuszmaul wrote:
> >>> This proposal does look like it would be helpful.   How does this
> >>> kind of proposal play out in terms of actually seeing the light of
> >>> day in deployed systems?
> >>
> >> We need some people to commit to implementing it.
> >>
> >> We have 2-3 testing events a year, so ideally we'd agree to show up wi=
th
> >> implementations at one of those to test and hash out any issues.
> >>
> >> We revise the draft based on any experience or feedback we get.  If
> >> nothing else, it looks like it needs some updates for v4.2.
> >>
> >> The on-the-wire protocol change seems small, and my feeling is that if
> >> there's running code then documenting the protocol and getting it
> >> through the IETF process shouldn't be a big deal.
> >>
> >> --b.
> >>
> >>> On 4/2/19 10:07 PM, bfields@fieldses.org wrote:
> >>>> On Wed, Apr 03, 2019 at 02:02:54AM +0000, Trond Myklebust wrote:
> >>>>> The create itself needs to be sync, but the attribute delegations m=
ean
> >>>>> that the client, not the server, is authoritative for the timestamp=
s.
> >>>>> So the client now owns the atime and mtime, and just sets them as p=
art
> >>>>> of the (asynchronous) delegreturn some time after you are done writ=
ing.
> >>>>>
> >>>>> Were you perhaps thinking about this earlier proposal?
> >>>>> https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__tools.ietf.o=
rg_html_draft-2Dmyklebust-2Dnfsv4-2Dunstable-2Dfile-2Dcreation-2D01&d=3DDwI=
BAg&c=3DRoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=3DYIKOmJLMLfe5wQR3VJI=
7jGjCnepZlMwumApzvaKItrY&m=3DqlAJ6dZPGjbcTzNIpkTyk-RTii6lWw1CLIjF6jp3P2Y&s=
=3DaTTFNJlRH-dXrQmE4cSYEUd8Kv3ij5cqTJtvgIixMa8&e=3D
> >>>> That's it, thanks!
> >>>>
> >>>> Bradley is concerned about performance of something like untar on a
> >>>> backend filesystem with particularly high-latency metadata operation=
s,
> >>>> so something like your unstable file createion proposal (or actual w=
rite
> >>>> delegations) seems like it should help.
> >>>>
> >>>> --b.
> >
> > The serialized create with something like an untar is a
> > performance-killer though.
> >
> > FWIW, I'm working on something similar right now for Ceph. If a ceph
> > client has adequate caps [1] for a directory and the dentry inode,
> > then we should (in principle) be able to buffer up directory morphing
> > operations and flush them out to the server asynchronously.
> >
> > I'm starting with unlink (mostly because it's simpler), and am mainly
> > just returning early when we do have the right caps -- after issuing
> > the call but before the reply comes in. We should be able to do the
> > same for link, rename and create too. Create will require the Ceph MDS
> > to delegate out a range of inode numbers (and that bit hasn't been
> > implemented yet).
> >
> > My thinking with all of this is that the buffering of directory
> > morphing operations is not as helpful as something like a pagecache
> > write is, as we aren't that interested in merging operations that
> > change the same dentry. However, being able to do them asynchronously
> > should work really well. That should allow us to better parallellize
> > create/link/unlink/rename on different dentries even when they are
> > issued serially by a single task.
>
> What happens if an asynchronous directory change fails (eg. ENOSPC)?
>

We have a well-established expectation with most local filesystems
that directory changes are not necessarily persisted until you issue
fsync on the parent(s). My thinking is that we'd report these sorts of
errors to that fsync.

All of this is _really_ experimental so far, so I don't claim to have
worked out all of the gory details as of yet. :)
--=20
Jeff Layton <jlayton@poochiereds.net>
