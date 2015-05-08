Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134AbbEHP31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 11:29:27 -0400
Date: Fri, 8 May 2015 11:29:18 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Olga Kornievskaia <aglo@umich.edu>
cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
 BAD_STATEID
In-Reply-To: <CAN-5tyHBPU8Hd0L+Ubf6GfoGK+LQ+Smf7tChr-o2-kb=kysQDA@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1505081125390.656@planck.local>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com> <110354172.1516782.1431074928783.JavaMail.zimbra@desy.de> <alpine.OSX.2.19.9992.1505080824560.656@planck.local> <752919938.1601268.1431090048609.JavaMail.zimbra@desy.de>
 <alpine.OSX.2.19.9992.1505080906070.656@planck.local> <418948160.1602341.1431090793667.JavaMail.zimbra@desy.de> <CAN-5tyHBPU8Hd0L+Ubf6GfoGK+LQ+Smf7tChr-o2-kb=kysQDA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 8 May 2015, Olga Kornievskaia wrote:

> Hi Tigran,
>
> I think you are hitting something else as mine is as you mentioned has
> to do with delegation. Also, RHEL6.6 code is very different from
> RHEL7.1 (or upstream). I haven't tested my test case on RHEL6.6 but
> just looking at it, I don't think it has the same OPEN loop problem.
>
> Ben,
>
> I didn't include this in my original message but we do have BZ open
> for the problem by Jorge Mora,
> Bug 1219184:
> Infinite OPEN loop on NFSv4.0 when I/O receives NFS4ERR_BAD_STATEID
>
> https://bugzilla.redhat.com/show_bug.cgi?id=1219184

Hi Olga,

Yep, I'm working that one.  My ONTAP sims got purged, so I've been setting
them back up this morning.

Ben


> On Fri, May 8, 2015 at 9:13 AM, Mkrtchyan, Tigran
> <tigran.mkrtchyan@desy.de> wrote:
> > No, Olga's case includes delegation, which our server does not supports.
> >
> > Tigran.
> >
> > ----- Original Message -----
> >> From: "Benjamin Coddington" <bcodding@redhat.com>
> >> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> >> Cc: "Olga Kornievskaia" <aglo@umich.edu>, "Trond Myklebust" <trond.myklebust@primarydata.com>, "linux-nfs"
> >> <linux-nfs@vger.kernel.org>
> >> Sent: Friday, May 8, 2015 3:08:03 PM
> >> Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting BAD_STATEID
> >
> >> Yes, I've done that, and the client's behavior correctly cycles through
> >> OPEN, then READ with the new stateid.  Are you able to create what Olga's
> >> talking about -- which is (I believe) a loop of just OPENs?
> >>
> >> Ben
> >>
> >> On Fri, 8 May 2015, Mkrtchyan, Tigran wrote:
> >>
> >>> Hi Ben,
> >>>
> >>> probably you can simulate, as Olga has suggested, with fault injection.
> >>> I can I can prepare a snadalone version of your server, which returns
> >>> BAD_STATEID on any IO request.
> >>>
> >>> Tigran.
> >>>
> >>> ----- Original Message -----
> >>> > From: "Benjamin Coddington" <bcodding@redhat.com>
> >>> > To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> >>> > Cc: "Olga Kornievskaia" <aglo@umich.edu>, "Trond Myklebust"
> >>> > <trond.myklebust@primarydata.com>, "linux-nfs"
> >>> > <linux-nfs@vger.kernel.org>
> >>> > Sent: Friday, May 8, 2015 2:25:19 PM
> >>> > Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
> >>> > BAD_STATEID
> >>>
> >>> > On Fri, 8 May 2015, Mkrtchyan, Tigran wrote:
> >>> >
> >>> >> Hi Olga,
> >>> >>
> >>> >> I believe we see the same infinite loop without delegation with RHEL6/7
> >>> >> kernels, but without delegation being involved. Currently, on the server
> >>> >> side, if client looping is detected, we return RESOURCE. This breaks the
> >>> >> loop and application gets an IO error.
> >>> >>
> >>> >> Your fix is only covers the delegation case isn't it?
> >>> >>
> >>> >> Tigran.
> >>> >
> >>> > Tigran, do you have a BZ or can you tell me how to reproduce this?
> >>> >
> >>> > Ben
> >>> > --
> >>> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>> > the body of a message to majordomo@vger.kernel.org
> >>> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
