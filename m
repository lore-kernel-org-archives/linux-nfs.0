Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34072 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754699AbbCRPS6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2015 11:18:58 -0400
Date: Wed, 18 Mar 2015 11:18:55 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Peng Yu <pengyu.ut@gmail.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS hang after concurrent writes
In-Reply-To: <CABrM6wmcSE_iZ1tjdYO9716aoxprP+06UcaDL759S1ATsNjDjA@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1503181117010.947@planck.local>
References: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com> <alpine.OSX.2.19.9992.1503100423290.456@planck.local> <CABrM6w=PoXHM9d6oSwsBK0ea7jxoyJ29TV0M_q-71qr_RykCKQ@mail.gmail.com> <alpine.OSX.2.19.9992.1503100735000.456@planck.local>
 <CABrM6w=YWhEHfJmhVxwS3bEGn3vFjysxkay1dXS=iZVumUcpAA@mail.gmail.com> <alpine.OSX.2.19.9992.1503111012530.947@planck.local> <CABrM6wmcSE_iZ1tjdYO9716aoxprP+06UcaDL759S1ATsNjDjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Mar 2015, Peng Yu wrote:

> >> http://wiki.linux-nfs.org/wiki/index.php/General_troubleshooting_recommendations#Capturing_a_Network_Trace
> >>
> >> Could you help show the detailed proceedure on how to do network capture to debug this specific issue if there is anything better
> >> than that in the above instruction ?
> >>
> > Those instructions are fine.
>
> Just to be sure. I following this procedure when this problem occurs, right?

Yes.  If you can reliably reproduce the problem, a network capture of the
NFS traffic between the client and server as you produce the problem would
be very helpful.

Ben
