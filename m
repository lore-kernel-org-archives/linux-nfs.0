Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:49366 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751097AbaKKPPQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2014 10:15:16 -0500
Date: Tue, 11 Nov 2014 10:15:12 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: Weston Andros Adamson <dros@primarydata.com>
cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: mount default minor version behavior
In-Reply-To: <CA0FEA36-5A18-41B6-8F7E-31376B67BA31@primarydata.com>
Message-ID: <alpine.LRH.2.11.1411111007380.20279@sh-el6.eng.rdu2.redhat.com>
References: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com> <CA0FEA36-5A18-41B6-8F7E-31376B67BA31@primarydata.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="168445344-1520829779-1415718913=:20279"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--168445344-1520829779-1415718913=:20279
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT


On Tue, 11 Nov 2014, Weston Andros Adamson wrote:

>
> > On Nov 11, 2014, at 9:39 AM, Benjamin Coddington <bcodding@redhat.com> wrote:
> >
> > I will update mount.nfs so the default version is 4.1.  I have two quick
> > questions on desired behavior:
> >
> > o  Should mounts that do not specify a minor version be upgraded to the default minor version?
> >
> > For example, should 'mount -overs=4' turn into 'mount -overs4.1', if the
> > current default is 4.1?
>
> No. We don’t want to change the minor version of mounts in users’ fstabs. The lack of a minor
> version in mount options has always meant minor version 0.
>
> What you’re talking about is making the default (i.e. when no version is specified) to be v4.1,
> right? I think we definitely want to auto retry in this case, i.e. try v4.1, then v4.0, then v3.

Correct.  When no version is specified, it will be v4.1, and we'll
auto-retry.  You are correct - my  question is what do do when a major
version is specified, but not a minor version.

You're firmly on the side that lack of a minor version means use '0' for a
minor version.

The reason I ask: most would say if you're going to use v4, use v4.1.  I
want to know if we want that general opinion reflected in the behavior of
mount choosing the current "best" minor version.

Ben


>
> -dros
>
> >
> >
> > o If 'yes' to the above, should mount auto-retry decrementing minor
> > versions if EPROTONOSUPPORT?
> >
> > For example, 'mount -overs=4' with a default of 4.2 would attempt: 4.2,
> > then 4.1, then 4.0.
> >
> > Ben
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
--168445344-1520829779-1415718913=:20279--
