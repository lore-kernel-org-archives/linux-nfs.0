Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:38682 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753789AbdIEWbm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Sep 2017 18:31:42 -0400
Received: by mail-io0-f172.google.com with SMTP id q64so20445059iod.5
        for <linux-nfs@vger.kernel.org>; Tue, 05 Sep 2017 15:31:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E7FE08F-D3EB-4AE2-8F8A-0688B68DA8B5@monkey.org>
References: <CAOFvWm9a6zrAc60Y388czZtUdL79Wf7AAaA=vTpAwS313Y44yg@mail.gmail.com>
 <F24109A7-778E-4655-BE5F-DCF2528E3A61@monkey.org> <4E7FE08F-D3EB-4AE2-8F8A-0688B68DA8B5@monkey.org>
From: Kjetil Joergensen <kjetil@medallia.com>
Date: Tue, 5 Sep 2017 15:31:41 -0700
Message-ID: <CAOFvWm8gJWZ=U1fU+hMjozt9ZW4qZVoV08HK1Wb+=OfE3OYNxw@mail.gmail.com>
Subject: Re: linux>=4.10: PUTFH|GETATTR|CLOSE, GETATTR fails, CLOSE not re-issued
To: Weston Andros Adamson <dros@monkey.org>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Thorvald Natvig <thorvald@medallia.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Tue, Sep 5, 2017 at 10:51 AM, Weston Andros Adamson <dros@monkey.org> wrote:
>
> I chatted with Trond about this and he says it's a server bug if an unlinked file
> keeps stateids around - the client doesn't need to issue a close in this case.

We don't disagree that this is a bug with the server, it is after all
a rather efficient
denial-of-service attack against it (Especially if you don't dismantle
your clients
all that often).

Although, not calling CLOSE under certain circumstances doesn't seem correct.

Continuing to cherrypick from RFCs:

RFC5661 - 8.2.4.  Stateid Lifetime and Validation
   Stateids must remain valid until either a client restart or a server
   restart or until the client returns all of the locks associated with
   the stateid by means of an operation such as CLOSE or DELEGRETURN.
   If the locks are lost due to revocation, as long as the client ID is
   valid, the stateid remains a valid designation of that revoked state
   until the client frees it by using FREE_STATEID.

> What version of ONTAP are you running?

Version: NetApp Release 8.2.4P6 7-Mode: Wed Jan 11 01:07:08 PST 2017


>
>
> -dros
>
>
> > On Sep 1, 2017, at 2:44 PM, Weston Andros Adamson <dros@monkey.org> wrote:
> >
> > Nice analysis! I think post d8d849835eb2082ea17655538a83fa467633927f, we
> > need to retry with a [PUTFH, CLOSE] if the GETATTR fails.
> >
> > The problem as I see it is the GETATTR is tied to the CURRENT_FH, which is
> > stale for new operations since the file was unlinked, but the CLOSE is tied to the
> > (CURRENT_FH, open stateid) pair and is not stale because the state id is still
> > valid.
> >
> > Trond is out on PTO, should be back on or before next Tuesday. The recent change
> > was his and he might have a better idea how to handle this.
> >
> > -dros
> >
> >
> >> On Aug 31, 2017, at 1:34 PM, Kjetil Joergensen <kjetil@medallia.com> wrote:
> >>
> >> Hi,
> >>
> >> (Now - I do not actually know the specification(s) all that well, so
> >> it may be that I've by accident cherry picked the bits that partially
> >> turns this into a linux-nfs-client bug, and I'd be more than happy
> >> with responses that'd be useful to yell at netapp with).
> >>
> >> after d8d849835eb2082ea17655538a83fa467633927f (NFSv4: Place the
> >> GETATTR operation before the CLOSE). If GETATTR actually fails, CLOSE
> >> will never be processed by the server, and it seems the linux nfs
> >> client never tries to re-issue CLOSE.
> >>
> >> We have client A holding file F open,  client B goes ahead and unlinks
> >> F, at some point client a does PUTFH,GETATTR, for which the server
> >> responds NFS4ERR_STALE.
> >>
> >> Now, client A goes ahead and tries to clean up it's internal state,
> >> and sends the server compound PUTFH,GETATTR,CLOSE, for which the
> >> server responds with PUTFH(NFS4_OK),GETATTR(NFS4ERR_STALE).
> >>
> >> Which seems correct in the eyes of RFC7530 section 14.2., which says
> >> the server should stop processing the compound when a subop fails.
> >>
> >> The server has not processed the CLOSE op, and in the case of netapp
> >> it appears it keeps holding on to the stateid, waiting for the client
> >> to CLOSE it.
> >>
> >> Judging from tcpdump, the client never attempts to re-issue the CLOSE
> >> op that weren't processed.
> >>
> >> On the server side, the stateid sticks around until we tear down the
> >> client completely (umount or re-boot). Over time, this leads the
> >> netapp to bleed stateids.
> >>
> >> Compare this to pre d8d849835eb2082ea17655538a83fa467633927f, the
> >> client issues PUTFH,CLOSE,GETATTR. Both PUTFH & CLOSE succeeds,
> >> GETATTR as expected still gets NFS4ERR_STALE. The server did however
> >> process CLOSE, and retired it's stateid.
> >>
> >> Cheers,
> >>
> >> --
> >> Kjetil Joergensen <kjetil@medallia.com>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
>



-- 
Kjetil Joergensen <kjetil@medallia.com>
SRE, Medallia Inc
