Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fn.samba.org ([216.83.154.106]:50833 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107Ab2K2W0j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2012 17:26:39 -0500
Message-ID: <1354227998.4064.11.camel@pico.ipa.ssimo.org>
Subject: Re: Possible to make nfs aware of a inotify watch has been set.
From: simo <idra@samba.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Stef Bon <stefbon@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>
Date: Thu, 29 Nov 2012 17:26:38 -0500
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA90B32D9D4@SACEXCMBX04-PRD.hq.netapp.com>
References: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B329CFD@SACEXCMBX04-PRD.hq.netapp.com>
	 <CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
	 <1354202525.4064.1.camel@pico.ipa.ssimo.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
	 <CANXojcys4wR8N-R3oSjWRWJLsObn0Qf+i41vBUaNnJctdcrKVw@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B32B2A0@SACEXCMBX04-PRD.hq.netapp.com>
	 <1354219557.4064.7.camel@pico.ipa.ssimo.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B32D9D4@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2012-11-29 at 21:09 +0000, Myklebust, Trond wrote:
> On Thu, 2012-11-29 at 15:05 -0500, simo wrote:
> > On Thu, 2012-11-29 at 17:11 +0000, Myklebust, Trond wrote:
> > > The idea that "if we build a bridge, they will come to us" is what
> > > gave
> > > rise to dnotify, then inotify (nobody came, so let's build a bigger
> > > bridge) and fsnotify (make it a toll bridge). Nobody is using those
> > > interfaces much on local filesystems, so why is adding it to NFS and
> > > CIFS going to be such a game changer?
> > 
> > Sorry Trond,
> > but this is simply not true.
> > 
> > inotify is a key feature at least in some packages I know, and makes
> > some things *a lot* easier.
> > 
> > Of course this are less visible features, that are easy to overlook, but
> > they are not unused for sure.
> 
> So why is it so difficult for anyone in this thread to name these killer
> applications that would benefit from NFS+CIFS support? I keep asking,
> and all I get is wishy-washy and hand-wavy answers.
> 
> Without use cases, there is nothing to discuss on the implementation
> front.

Sorry for the misunderstanding, I wasn't talking about inotify *on
CIFS/NFS*, I do not care about that use case, I'll gladly let Stef pitch
it for himself :)

Simo.

-- 
Simo Sorce
Samba Team GPL Compliance Officer <simo@samba.org>
Principal Software Engineer at Red Hat, Inc. <simo@redhat.com>

