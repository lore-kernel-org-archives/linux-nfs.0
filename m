Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751353AbbEHNIM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2015 09:08:12 -0400
Date: Fri, 8 May 2015 09:08:03 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
cc: Olga Kornievskaia <aglo@umich.edu>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting
 BAD_STATEID
In-Reply-To: <752919938.1601268.1431090048609.JavaMail.zimbra@desy.de>
Message-ID: <alpine.OSX.2.19.9992.1505080906070.656@planck.local>
References: <CAN-5tyG8ukoGJATK1RA85xv9BDikfC1CPP0nc=-80h=BSGV6=w@mail.gmail.com> <110354172.1516782.1431074928783.JavaMail.zimbra@desy.de> <alpine.OSX.2.19.9992.1505080824560.656@planck.local> <752919938.1601268.1431090048609.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Yes, I've done that, and the client's behavior correctly cycles through
OPEN, then READ with the new stateid.  Are you able to create what Olga's
talking about -- which is (I believe) a loop of just OPENs?

Ben

On Fri, 8 May 2015, Mkrtchyan, Tigran wrote:

> Hi Ben,
>
> probably you can simulate, as Olga has suggested, with fault injection.
> I can I can prepare a snadalone version of your server, which returns
> BAD_STATEID on any IO request.
>
> Tigran.
>
> ----- Original Message -----
> > From: "Benjamin Coddington" <bcodding@redhat.com>
> > To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> > Cc: "Olga Kornievskaia" <aglo@umich.edu>, "Trond Myklebust" <trond.myklebust@primarydata.com>, "linux-nfs"
> > <linux-nfs@vger.kernel.org>
> > Sent: Friday, May 8, 2015 2:25:19 PM
> > Subject: Re: 4.0 NFS client in infinite loop in state recovery after getting BAD_STATEID
>
> > On Fri, 8 May 2015, Mkrtchyan, Tigran wrote:
> >
> >> Hi Olga,
> >>
> >> I believe we see the same infinite loop without delegation with RHEL6/7
> >> kernels, but without delegation being involved. Currently, on the server
> >> side, if client looping is detected, we return RESOURCE. This breaks the
> >> loop and application gets an IO error.
> >>
> >> Your fix is only covers the delegation case isn't it?
> >>
> >> Tigran.
> >
> > Tigran, do you have a BZ or can you tell me how to reproduce this?
> >
> > Ben
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
