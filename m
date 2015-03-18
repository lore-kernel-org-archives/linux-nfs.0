Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34355 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474AbbCRPag (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2015 11:30:36 -0400
Date: Wed, 18 Mar 2015 11:30:34 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Peng Yu <pengyu.ut@gmail.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS hang after concurrent writes
In-Reply-To: <CABrM6wnv10Yr48U_1sfWosR7Rzc3bOq2Jc2XZJfGh1qdgb+ZQg@mail.gmail.com>
Message-ID: <alpine.OSX.2.19.9992.1503181130100.947@planck.local>
References: <CABrM6wnked-ZShCTC2cT-UNA+wrLPA5hmCJNhbXi-hirbE5RMw@mail.gmail.com> <alpine.OSX.2.19.9992.1503100423290.456@planck.local> <CABrM6w=PoXHM9d6oSwsBK0ea7jxoyJ29TV0M_q-71qr_RykCKQ@mail.gmail.com> <alpine.OSX.2.19.9992.1503100735000.456@planck.local>
 <CABrM6w=YWhEHfJmhVxwS3bEGn3vFjysxkay1dXS=iZVumUcpAA@mail.gmail.com> <alpine.OSX.2.19.9992.1503111012530.947@planck.local> <CABrM6wmcSE_iZ1tjdYO9716aoxprP+06UcaDL759S1ATsNjDjA@mail.gmail.com> <alpine.OSX.2.19.9992.1503181117010.947@planck.local>
 <CABrM6wnv10Yr48U_1sfWosR7Rzc3bOq2Jc2XZJfGh1qdgb+ZQg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 18 Mar 2015, Peng Yu wrote:

> > Yes.  If you can reliably reproduce the problem, a network capture of the
> > NFS traffic between the client and server as you produce the problem would
> > be very helpful.
>
> It sounds the solution can be simpler than this.
>
> Here is the current problem.
>
> It hangs when I login to the server using an account with the home
> directory mounted via NFS.
>
> I login to another server on which the same NFS directory is mounted
> and I can delete the file corresponding to ~/.bash_history on the
> first server.
>
> When try to login the first server, it still hangs. When I login this
> server using another account without NFS mounted as home, I can see
> there is a file ~/.nfs000000160000351200000001 in the first account's
> home (but not ~/.bash_history anymore). After I delete
> ~/.nfs000000160000351200000001 in the first account home, I am able to
> login using the first account.
>
> Can anybody pinpoint the cause of the problem given the above description?

That's expected behavior, see: http://nfs.sourceforge.net/#faq_d2

Ben
