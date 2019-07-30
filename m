Return-Path: <SRS0=Ztr/=V3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E99A5C433FF
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Jul 2019 15:55:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B996920693
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Jul 2019 15:55:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726840AbfG3Pz3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 30 Jul 2019 11:55:29 -0400
Received: from fieldses.org ([173.255.197.46]:41514 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726501AbfG3Pz3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 Jul 2019 11:55:29 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id B4A7BC56; Tue, 30 Jul 2019 11:55:28 -0400 (EDT)
Date:   Tue, 30 Jul 2019 11:55:28 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 4/8] NFSD add COPY_NOTIFY operation
Message-ID: <20190730155528.GE31707@fieldses.org>
References: <20190708192352.12614-1-olga.kornievskaia@gmail.com>
 <20190708192352.12614-5-olga.kornievskaia@gmail.com>
 <20190717230726.GA26801@fieldses.org>
 <CAN-5tyHmODP2+nMiinTEP5WZzXz=m=j9LBSWv=b=N3C211JaLg@mail.gmail.com>
 <20190723204537.GA19559@fieldses.org>
 <CAN-5tyGL+BR+1E1N-HzH3-mmjze8AkBHpYAm0k3i0Dt+iP1ORQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAN-5tyGL+BR+1E1N-HzH3-mmjze8AkBHpYAm0k3i0Dt+iP1ORQ@mail.gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jul 30, 2019 at 11:48:27AM -0400, Olga Kornievskaia wrote:
> On Tue, Jul 23, 2019 at 4:46 PM J. Bruce Fields <bfields@fieldses.org> wrote:
> >
> > On Mon, Jul 22, 2019 at 04:17:44PM -0400, Olga Kornievskaia wrote:
> > > Let me see if I understand your suspicion and ask for guidance how to
> > > resolve it as perhaps I'm misusing the function. idr_alloc_cyclic()
> > > keeps track of the structure of the 2nd arguments with a value it
> > > returns. How do I initiate the structure with the value of the
> > > function without knowing the value which can only be returned when I
> > > call the function to add it to the list? what you are suggesting is to
> > > somehow get the value for the new_id but not associate anything then
> > > update the copy structure with that value and then call
> > > idr_alloc_cyclic() (or something else) to create that association of
> > > the new_id and the structure? I don't know how to do that.
> >
> > You could move the initialization under the s2s_cp_lock.  But there's
> > additional initialization that's done in the caller.
> 
> I still don't understand what you are looking for here and why. I'm
> following what the normal stid allocation does.  There is no extra code
> there to see if it initiated or not. nfs4_alloc_stid() calls
> idr_alloc_cyclic() creates an association between the stid pointer and
> at the time uninitialized nfs4_stid structure which is then filled in
> with the return of the idr_alloc_cyclic(). That's exactly what the new
> code is doing (well accept that i'll change it to store the
> stateid_t).

Yes, I'm a little worried about normal stid allocation too.  It's got
one extra safeguard because of the check for 0 sc_type in the lookup,
I haven't yet convinced myself that's enough.

The race I'm worried about is: one task does the idr allocation and
drops locks.  Before it has the chance to finish initializing the
object, a second task looks it up in the idr and does something with it.
It sees the not-yet-initialized fields.

--b.
