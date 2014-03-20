Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f53.google.com ([209.85.219.53]:34485 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870AbaCTHgt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Mar 2014 03:36:49 -0400
Received: by mail-oa0-f53.google.com with SMTP id j17so482427oag.40
        for <linux-nfs@vger.kernel.org>; Thu, 20 Mar 2014 00:36:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1394732462.32465.235.camel@willson.li.ssimo.org>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
	<5321CDB6.7010803@RedHat.com>
	<1394729939.32465.231.camel@willson.li.ssimo.org>
	<20140313172531.GA7124@fieldses.org>
	<1394732462.32465.235.camel@willson.li.ssimo.org>
Date: Thu, 20 Mar 2014 09:36:49 +0200
Message-ID: <CAOoFWK8xG5fRbNifoAp48u8UhXtB+AuPKy4ssSGi1_d+K2QFiw@mail.gmail.com>
Subject: Re: [PATCH v2 0/5] NFSv4 rpc.idmapd plugin
From: Noam Meltzer <noam@primarydata.com>
To: Simo Sorce <simo@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        sssd-devel <sssd-devel@lists.fedorahosted.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 13, 2014 at 7:41 PM, Simo Sorce <simo@redhat.com> wrote:
>
> On Thu, 2014-03-13 at 13:25 -0400, J. Bruce Fields wrote:
> > On Thu, Mar 13, 2014 at 12:58:59PM -0400, Simo Sorce wrote:
> > > On Thu, 2014-03-13 at 11:24 -0400, Steve Dickson wrote:
> > >
> > > > V4 servers now have an option of returning a uid string (aka "3606")
> > > > where the NFS client just converts that into the uid.
> > >
> > > Can the client tell the server *not to do that* ?
> >
> > The client can use kerberos, in which case the server won't do that.
>
> This is sufficient, thanks.
>
> > Other than that, no, the behavior can only be controlled by server-side
> > configuration.
>
> A little sub-optimal if the server can do either but the client can have
> a choice, but ok.
>

Sorry for the late response. A misplaced email filtering rule had
moved it away from my inbox.
How can we push this forward?


-- 
Noam Meltzer
Linux Software Engineer
PRIMARY DATA

P.O. Box 12650, Herzliya Pituach 4673300
9 Hamenofim St. Akerstein Towers, Tower A, 5th fl. Herzliya

Office: +972-77-8981888 | Fax: +972-3-7617140 | Mobile: +972-54-5873843

Email: noam@primarydata.com
