Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:48483 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbbDIVIj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Apr 2015 17:08:39 -0400
Message-ID: <5526EA56.4080606@candelatech.com>
Date: Thu, 09 Apr 2015 14:08:38 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: Gregory Boyce <gregory.boyce@gmail.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: Problems mounting via UDP from a netapp with multiple interfaces
References: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
In-Reply-To: <CALs61ueTJ4_WT00Sqz5TKzhkbrS32UjcQ0zVw6B8ikahE4Rhcw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/09/2015 12:34 PM, Gregory Boyce wrote:
> Folks,
> 
> I've been encountering a problem with NFS clients attempting to mount
> from a netapp via UDP where the netapp is responding on the wrong
> interface.  On some of our older systems, this mount worked properly,
> while on newer systems nfs-utils ends up failing the mount.  Mounting
> via TCP works fine.
> 
> It appears that there has been various related discussions over the
> years, and a relevant Redhat bug opened back in 2006:
> 
> http://article.gmane.org/gmane.linux.nfs/22778/match=connect+udp
> https://bugzilla.redhat.com/show_bug.cgi?id=208244
> 
> Is there a general recommendation for people in this sort of
> situation?  I'm assuming the code is currently using connected UDP
> sockets (I'm more of a sysadmin than a developer).  Is there an option
> I'm missing to disable this?  Otherwise does anyone know of a patch to
> change the behavior?

I have some patches that allow binding an NFS client to a particular
local IP.  You need modified mount.nfs tools as well.  These patches
might fix your problem, but I am not certain about that.

My kernel trees have various other patches as well...you can pick out just
the NFS stuff if you care to.  Otherwise, the kernel should generally build,
install, and work the same as upstream kernels.

https://github.com/greearb/nfs-utils-ct

# This one has cleaner patch set, but not much testing.
http://dmz2.candelatech.com/git/gitweb.cgi?p=linux-3.19.dev.y/.git;a=summary

# This is lots of extraneous wifi patches, but has had good testing,
# including the nfs bind-to-local-IP feature.

http://dmz2.candelatech.com/git/gitweb.cgi?p=linux-3.17.dev.y/.git;a=summary


Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

