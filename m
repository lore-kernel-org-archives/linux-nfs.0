Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-8.concepts.nl ([213.197.30.117]:55611 "EHLO
	smtp-8.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266Ab1JVLMx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Oct 2011 07:12:53 -0400
Received: from d594e6a3.dsl.concepts.nl ([213.148.230.163] helo=gnome.loos.site)
	by smtp-4.concepts.nl with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <aelschuring@hotmail.com>)
	id 1RHZVO-0008Ah-R7
	for linux-nfs@vger.kernel.org; Sat, 22 Oct 2011 13:12:46 +0200
Received: from [172.22.21.203] (helo=neminis.intra.loos.site)
	by gnome.loos.site with esmtp (Exim 4.72)
	(envelope-from <aelschuring@hotmail.com>)
	id 1RHZVO-0004D1-HS
	for linux-nfs@vger.kernel.org; Sat, 22 Oct 2011 13:12:46 +0200
Date: Sat, 22 Oct 2011 13:12:45 +0200
From: Arno Schuring <aelschuring@hotmail.com>
To: linux-nfs@vger.kernel.org
Subject: Re: sec=krb5 mounts never return
Message-ID: <20111022131245.7387d2d3@neminis.intra.loos.site>
In-Reply-To: <4EA1E793.3060407@anl.gov>
References: <20111021012327.612839b5@neminis.loos.site>
	<CAKnQG+d66Driv-D7fTeyh=MP4iNqpTzjXyFEiLE34E3YV2KG_g@mail.gmail.com>
	<20111021221001.71628099@neminis.intra.loos.site>
	<CAKnQG+d6V4sjY8i0-kLvUPGLgY+m8R3+yTqzdMaF3rsfWq2RYQ@mail.gmail.com>
	<4EA1E793.3060407@anl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Douglas E. Engert (deengert@anl.gov on 2011-10-21 16:43 -0500):
> If the enctype=4 and length= 8 that sounds like DES.
> You may need to add to the krb5.conf file,
> 
>   allow_weak_crypto = yes

That's there. I'm not particularly happy about it, but it is my
understanding that 2.6.32 does not allow strong crypto for nfs4.

> 
> On 10/21/2011 3:58 PM, Kevin Coffman wrote:
> >>
> >> In this case I'm trying with a local mount, so client==server. The
> >> gssd logs invariably end with the following lines:
> >> rpc.gssd[26133]: creating context with server nfs@genie.loos.site
> >> rpc.gssd[28189]: DEBUG: serialize_krb5_ctx: lucid version!
> >> rpc.gssd[28189]: prepare_krb5_rfc1964_buffer: serializing keys with
> >> enctype 4 and length 8
> >> rpc.gssd[28189]: doing downcall
> >> [ then nothing until I kill the mount process ]
> >>
> >> In the svcgssd logs, nothing stands out to me. It all appears
> >> proper to the untrained eye:
> >>
> >> rpc.svcgssd[26188]: handling null request
> >> rpc.svcgssd[26188]: sname = nfs/genie.loos.site@LOOS.SITE
> >> rpc.svcgssd[26188]: libnfsidmap: using (default) domain: loos.site
> >> rpc.svcgssd[26188]: DEBUG: serialize_krb5_ctx: lucid version!
> >> rpc.svcgssd[26188]: prepare_krb5_rfc1964_buffer: serializing keys
> >> with enctype 4 and length 8
> >> rpc.svcgssd[26188]: doing downcall
> >> rpc.svcgssd[26188]: mech: krb5, hndl len: 4, ctx len 85, timeout:
> >> 1319183270 (35999 from now), clnt: nfs@genie.loos.site, uid: -1,
> >> gid: -1, num aux grps: 0:
> >> rpc.svcgssd[26188]: sending null reply
> >> rpc.svcgssd[26188]: finished handling null request
> >>
> > The userland/daemon stuff all looks fine to me.  I'm not as familiar
> > with the kernel logs.  I believe the following kernel messages are
> > from the ^C:
> >
Indeed. 23:47 is the mount command, 23:48 is the ^C. I see I did not
even allow 30s before killing, but I've had similar results even when
waiting minutes.

> >
> > I don't see anything obviously wrong.
Thanks. Any kernel wizards that want to take a stab at this? I can
provide more input if required, but kernel traces are hard to get
because this is a NAS without console.


Regards,
Arno
