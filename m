Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:49680 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752947Ab2K2P1v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 10:27:51 -0500
Message-ID: <1354202525.4064.1.camel@pico.ipa.ssimo.org>
Subject: Re: Possible to make nfs aware of a inotify watch has been set.
From: simo <idra@samba.org>
To: Stef Bon <stefbon@gmail.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>
Date: Thu, 29 Nov 2012 10:22:05 -0500
In-Reply-To: <CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
References: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B329CFD@SACEXCMBX04-PRD.hq.netapp.com>
	 <CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-11-29 at 15:49 +0100, Stef Bon wrote:
> 2012/11/29 Myklebust, Trond <Trond.Myklebust@netapp.com>:
> >> -----Original Message-----
> >>
> >> 1. while the filesystems are using credentails or tickets to get access to a
> >> remote resource, this is a bit difficult for notifyfs.
> >> Notifyfs bypasses that. Maybe this leads to permissions/abuse I cannot see
> >> directly.
> >
> > Lack of security is a showstopper. There are good reasons why inotify won't allow you to monitor files for which you don't have access permissions.
> >
> 
> Let me explain, I think you not understand fully.
> 
> Notifyfs does not allow users/clients to set a watch if there are no
> read permissions (the object and access for the whole path to it), so
> there are no security issues there.
> 
> What I mean is that any program can contact the remote notifyfs
> server, and this remote notifyfs server cannot figure out it's a valid
> request from another notifyfs server, or a program faking that.
> In the construction I describe it does not check that (yet).
> 
> >>
> >> What do you think, is the latest option possible??
> >
> > So what is the killer app for inotify on NFS/CIFS/FUSE? What programs do you need to run on a NFS/CIFS/FUSE client that use inotify and that wouldn't be better off running on the server instead?
> >
> 
> What do you mean with "better off running on the server instead"?
> There are a lot of programs interested in fs changes, like a simple
> file manager. I think it's a very nice feature to see changes right
> away in the view.
> It's not a killer app, but a think the whole user experience is
> improving when your system is able to keep a view (like a view in the
> file manager) up to date.
> 
> > IOW: whose problem are you trying to solve?
> 
> I think that enabling fs notify on network filesystems like nfs, cifs
> and fuse is a good thing (see above). On systems like Windows and iOS
> since long time this works.

CIFS has notification capabilities built in (oplocks), as does NFS
(leases), is this not sufficient ?

Simo.

-- 
Simo Sorce
Samba Team GPL Compliance Officer <simo@samba.org>
Principal Software Engineer at Red Hat, Inc. <simo@redhat.com>

