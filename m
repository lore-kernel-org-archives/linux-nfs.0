Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDF62C4360F
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:10:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7CB27206DD
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 15:10:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=poochiereds-net.20150623.gappssmtp.com header.i=@poochiereds-net.20150623.gappssmtp.com header.b="mGh7NHUL"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729140AbfDDPKC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 11:10:02 -0400
Received: from mail-ed1-f45.google.com ([209.85.208.45]:46157 "EHLO
        mail-ed1-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727212AbfDDPKB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Apr 2019 11:10:01 -0400
Received: by mail-ed1-f45.google.com with SMTP id d1so2514565edd.13
        for <linux-nfs@vger.kernel.org>; Thu, 04 Apr 2019 08:10:00 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=poochiereds-net.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=d9L9/pCIRpqYW+085WFvD/j+h97m1n7hbhogjSowiag=;
        b=mGh7NHULZ63fy7S991Gt0T+20JKkJCYjeWqwyDtLRHNvV9bQ5VIxVKATvV1ELuO1j4
         0J4SG2HWXlkrMzg/bKiWeBVympPDQaM9he01moiAW+CGGhBYjfQTkEBnvfoCDmn6ZC54
         UMKOnW6Lz6PHIMsAQqI3pJU0IgN8k4B7+sNKF3PNIII38+3XeY5c9PY6OuO103IAUlH9
         P0TqFNldpDqpQQ81AWcjfYVKzqXwc3bME/Lt+OYa6776vgOanzG/gbqMlPyNn0lqyOlA
         y6iJBMOZnMzumSbYferU3+ZjreXQIi2serSxH8Dfg+4cbit1SmhbrkNYZ5QO4yMKtjuZ
         z9ZA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc:content-transfer-encoding;
        bh=d9L9/pCIRpqYW+085WFvD/j+h97m1n7hbhogjSowiag=;
        b=rIp0ncL9U8DPojbHWUIj22MWvabq0oejb756WiCs8MV8rMcyPL3IXs9Z6owcxEaKvw
         Ar9d8DBSJ7qzpM55wFjONeVBlb4qeIw1qe0ICQVUi+TuNmqzgNEKckCYKuxR6IQVUhKr
         H+AxjCn86EGbMSrnSwbPT5f3BCyFFPRcyx69fOdZJOpMXyYuORR8bcZEFlvX8YwR4ZUQ
         PUFoYSA24L0ZTT2HD0YmWynkwLFq5xXoEV/ZUzVrTWrUT4cDVkzUGhkkRgIxCKWsM7me
         LJn/yHhf5gUaxicC2APfxX17h7ilOFy5ni7wi6Edm10GrX4uk3DtXhYnS8cEfguyBccP
         S0dA==
X-Gm-Message-State: APjAAAWKyeBgHR32Mcu1eb7NBX+JWPtsg+FbvJ2sxKx3uQDukrVc1OZ3
        nbVdExc3Ljd+RgOEP+yKqAAP/cKkVBTCy1gEd0PMSw==
X-Google-Smtp-Source: APXvYqwFB0er3quelOXtxrORzp5kpdmu/kAY2eBRV0By+f9BzFPVMHWSDdNGlStwQxee7vXwuxH1xfO9/I1QTRdW4W8=
X-Received: by 2002:a17:906:960a:: with SMTP id s10mr3830505ejx.141.1554390599408;
 Thu, 04 Apr 2019 08:09:59 -0700 (PDT)
MIME-Version: 1.0
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org> <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
 <20190402194148.GA5269@fieldses.org> <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org> <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
 <20190403020750.GA8272@fieldses.org> <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
 <20190404010559.GA17840@fieldses.org>
In-Reply-To: <20190404010559.GA17840@fieldses.org>
From:   Jeff Layton <jlayton@poochiereds.net>
Date:   Thu, 4 Apr 2019 11:09:47 -0400
Message-ID: <CAOhYWNLZ2OmnGo2nEegmuXOrU_ncmAwWgQSAMXxKfn3JP-UMUw@mail.gmail.com>
Subject: Re: directory delegations
To:     "bfields@fieldses.org" <bfields@fieldses.org>
Cc:     "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Apr 3, 2019 at 9:06 PM bfields@fieldses.org
<bfields@fieldses.org> wrote:
>
> On Wed, Apr 03, 2019 at 12:56:24PM -0400, Bradley C. Kuszmaul wrote:
> > This proposal does look like it would be helpful.   How does this
> > kind of proposal play out in terms of actually seeing the light of
> > day in deployed systems?
>
> We need some people to commit to implementing it.
>
> We have 2-3 testing events a year, so ideally we'd agree to show up with
> implementations at one of those to test and hash out any issues.
>
> We revise the draft based on any experience or feedback we get.  If
> nothing else, it looks like it needs some updates for v4.2.
>
> The on-the-wire protocol change seems small, and my feeling is that if
> there's running code then documenting the protocol and getting it
> through the IETF process shouldn't be a big deal.
>
> --b.
>
> > On 4/2/19 10:07 PM, bfields@fieldses.org wrote:
> > >On Wed, Apr 03, 2019 at 02:02:54AM +0000, Trond Myklebust wrote:
> > >>The create itself needs to be sync, but the attribute delegations mea=
n
> > >>that the client, not the server, is authoritative for the timestamps.
> > >>So the client now owns the atime and mtime, and just sets them as par=
t
> > >>of the (asynchronous) delegreturn some time after you are done writin=
g.
> > >>
> > >>Were you perhaps thinking about this earlier proposal?
> > >>https://urldefense.proofpoint.com/v2/url?u=3Dhttps-3A__tools.ietf.org=
_html_draft-2Dmyklebust-2Dnfsv4-2Dunstable-2Dfile-2Dcreation-2D01&d=3DDwIBA=
g&c=3DRoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=3DYIKOmJLMLfe5wQR3VJI7j=
GjCnepZlMwumApzvaKItrY&m=3DqlAJ6dZPGjbcTzNIpkTyk-RTii6lWw1CLIjF6jp3P2Y&s=3D=
aTTFNJlRH-dXrQmE4cSYEUd8Kv3ij5cqTJtvgIixMa8&e=3D
> > >That's it, thanks!
> > >
> > >Bradley is concerned about performance of something like untar on a
> > >backend filesystem with particularly high-latency metadata operations,
> > >so something like your unstable file createion proposal (or actual wri=
te
> > >delegations) seems like it should help.
> > >
> > >--b.

The serialized create with something like an untar is a
performance-killer though.

FWIW, I'm working on something similar right now for Ceph. If a ceph
client has adequate caps [1] for a directory and the dentry inode,
then we should (in principle) be able to buffer up directory morphing
operations and flush them out to the server asynchronously.

I'm starting with unlink (mostly because it's simpler), and am mainly
just returning early when we do have the right caps -- after issuing
the call but before the reply comes in. We should be able to do the
same for link, rename and create too. Create will require the Ceph MDS
to delegate out a range of inode numbers (and that bit hasn't been
implemented yet).

My thinking with all of this is that the buffering of directory
morphing operations is not as helpful as something like a pagecache
write is, as we aren't that interested in merging operations that
change the same dentry. However, being able to do them asynchronously
should work really well. That should allow us to better parallellize
create/link/unlink/rename on different dentries even when they are
issued serially by a single task.

RFC5661 doesn't currently provide for writeable directory delegations,
AFAICT, but they could eventually be implemented in a similar way.

[1]: cephfs capabilies (aka caps) are like a delegation for a subset
of inode metadata
--
Jeff Layton <jlayton@poochiereds.net>
