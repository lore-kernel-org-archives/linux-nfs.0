Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44382 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097AbaKKPUt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2014 10:20:49 -0500
Date: Tue, 11 Nov 2014 10:20:44 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
In-Reply-To: <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>
Message-ID: <alpine.LRH.2.11.1411111017190.20279@sh-el6.eng.rdu2.redhat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CAHQdGtQSSeOWs9pzZoXzR_+2F69-EJQB5BOEkB7q9BVE-d=RFA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 11 Nov 2014, Trond Myklebust wrote:

> Hi Ben,
>
> On Tue, Nov 11, 2014 at 9:39 AM, Benjamin Coddington
> <bcodding@redhat.com> wrote:
> > I will update mount.nfs so the default version is 4.1.  I have two quick
> > questions on desired behavior:
> >
> >  o  Should mounts that do not specify a minor version be upgraded to the
> > default minor version?
> >
> > For example, should 'mount -overs=4' turn into 'mount -overs4.1', if the
> > current default is 4.1?
> >
> >
> >  o If 'yes' to the above, should mount auto-retry decrementing minor
> > versions if EPROTONOSUPPORT?
> >
> > For example, 'mount -overs=4' with a default of 4.2 would attempt: 4.2,
> > then 4.1, then 4.0.
> >
>
> One thing you should note when doing this: the current parser for
> /etc/nfsmount.conf does not support minor versions. I think it needs
> to, so that we can continue to use it to set defaults.
>
> ...and to answer your questions above, I think that we should be able
> to specify a 'default nfsv4 minor version' in /etc/nfsmount.conf, and
> then negotiate down from there.
> IOW: extend the 'Defaultvers' and 'Nfsvers' options to support 4.0,
> 4.1, 4.2,....

Ah, good idea to make it configurable.

> The result should be that If I do 'mount -t nfs' with no '-overs'
> option, then we start at 4.1 (if that is the default in
> /etc/nfsmount.conf) and then try 4.0, 3, 2 in that order.
> If I do 'mount -t nfs -overs=4', then again consult /etc/nfsmount.conf;
> - if there is a default matching a v4 minor version, then start at
> that and negotiate down (but stop at 4.0).

Yep, those closely match the current behavior and that's what my first
pass looks like.

> - if there is no default in /etc/nfsmount.conf, then perhaps assume a
> default of 0(????)

That's the question, and I think it will be a very common case.  Do we
want to have an idea of a "best" minor version, and use that if no minor
version is specified?

Ben

>
> Cheers
>   Trond
>
>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
>
