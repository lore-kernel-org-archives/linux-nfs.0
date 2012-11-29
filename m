Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:47624 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510Ab2K2Q2F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 11:28:05 -0500
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
References: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B329CFD@SACEXCMBX04-PRD.hq.netapp.com>
	<CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
	<1354202525.4064.1.camel@pico.ipa.ssimo.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
Date: Thu, 29 Nov 2012 10:28:04 -0600
Message-ID: <CAH2r5muVNPGx74ppc6MZPZRcsCRdP=xM4gvmrzEnw5bAb3jW8w@mail.gmail.com>
Subject: Re: Possible to make nfs aware of a inotify watch has been set.
From: Steve French <smfrench@gmail.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: simo <idra@samba.org>, Stef Bon <stefbon@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 29, 2012 at 9:33 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
> On Thu, 2012-11-29 at 10:22 -0500, simo wrote:
>> On Thu, 2012-11-29 at 15:49 +0100, Stef Bon wrote:
>> > 2012/11/29 Myklebust, Trond <Trond.Myklebust@netapp.com>:
>> > >> -----Original Message-----
>> > >>
>> > >> 1. while the filesystems are using credentails or tickets to get access to a
>> > >> remote resource, this is a bit difficult for notifyfs.
>> > >> Notifyfs bypasses that. Maybe this leads to permissions/abuse I cannot see
>> > >> directly.
>> > >
>> > > Lack of security is a showstopper. There are good reasons why inotify won't allow you to monitor files for which you don't have access permissions.
>> > >
>> >
>> > Let me explain, I think you not understand fully.
>> >
>> > Notifyfs does not allow users/clients to set a watch if there are no
>> > read permissions (the object and access for the whole path to it), so
>> > there are no security issues there.
>> >
>> > What I mean is that any program can contact the remote notifyfs
>> > server, and this remote notifyfs server cannot figure out it's a valid
>> > request from another notifyfs server, or a program faking that.
>> > In the construction I describe it does not check that (yet).
>> >
>> > >>
>> > >> What do you think, is the latest option possible??
>> > >
>> > > So what is the killer app for inotify on NFS/CIFS/FUSE? What programs do you need to run on a NFS/CIFS/FUSE client that use inotify and that wouldn't be better off running on the server instead?
>> > >
>> >
>> > What do you mean with "better off running on the server instead"?
>> > There are a lot of programs interested in fs changes, like a simple
>> > file manager. I think it's a very nice feature to see changes right
>> > away in the view.
>> > It's not a killer app, but a think the whole user experience is
>> > improving when your system is able to keep a view (like a view in the
>> > file manager) up to date.
>> >
>> > > IOW: whose problem are you trying to solve?
>> >
>> > I think that enabling fs notify on network filesystems like nfs, cifs
>> > and fuse is a good thing (see above). On systems like Windows and iOS
>> > since long time this works.
>>
>> CIFS has notification capabilities built in (oplocks), as does NFS
>> (leases), is this not sufficient ?
>
> NFSv4.1 actually has directory notifications which duplicate most of the
> functionality of dnotify. The question I'm asking is "Why should we do
> it?", not "can we do it?".
>
> Answers like "well Windows and iOS do it" aren't helpful unless they
> include a description of what Windows and iOS apps use it for that we
> can't already do on Linux.
> If the only application is beagle, then Linux has this really helpful
> utility called "ssh", which allows you to avoid wasting a load of
> network bandwidth...

Of course one reason that file managers like directory notifications is that
it avoids wasting a load of network bandwidth - as the alternative to
directory change
notifications is polling the directories for every open window.   Also note that
network file systems where possible should implement similar semantics and
interfaces to the local file systems, and inotify/dnotify are mappable
to network
'file systems (presumably not just cifs/smb2/smb3).   Support for
keeping file manager
views reasonably up to date would be a good enough reason for something like
inotify/dnotify (and it has been used by file managers for over 20
years, even before
Windows and iOS) - and we want to get to the point where home directories
work as well on network mounts as on local storage.

Directory oplocks (in smb3) may be helpful in reducing the number of remote
directory change notifications further.



-- 
Thanks,

Steve
