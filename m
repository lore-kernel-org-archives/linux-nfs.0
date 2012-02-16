Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39567 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747Ab2BPP6i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 10:58:38 -0500
Received: by eaah12 with SMTP id h12so833371eaa.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2012 07:58:36 -0800 (PST)
Message-ID: <4F3D27A6.4010200@tonian.com>
Date: Thu, 16 Feb 2012 17:58:30 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "Bhamare, Sachin" <sbhamare@panasas.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "osd-dev@open-osd.org" <osd-dev@open-osd.org>,
        "Harrosh, Boaz" <bharrosh@panasas.com>, Jim Rees <rees@umich.edu>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [osd-dev] nfs-utils: userspace support for autologin feature
 in object layout driver
References: <CB5990C9.679A%sbhamare@panasas.com>
In-Reply-To: <CB5990C9.679A%sbhamare@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-02-10 01:02, Bhamare, Sachin wrote:
> Hi, 
>    I have been working on implementing autologin support for objectlayout
> driver in pNFS client. This feature would allow pNFS object clients to
> receive an URI (e.g. iscsi://<IP>:<PORT>) of a target OSD via
> GETDEVICEINFO rpc from the server. Object layout driver would then pass
> this information to an user space daemon which would perform the login
> task 
> depending on the protocol involved (e.g. Iscsi login using iscsiadm).
> 
> For userspace daemon, we have 2 implementation choices.
> 
> 1. Add new daemon (say, osdlogind) to nfs-utils which would process the
> upcalls from object layout driver via rpc_pipefs (very similar to the way
> blkmapd works)
> 2. Modify blkmapd in nfs-utils package to be able to process upcalls from
> the object layout driver and add new functionality to process these
> messages.
> 
> I think, (1) above is the simplest and cleanest way to go about
> implementing this. (2) adds an indirect dependency between block layout
> driver and object layout driver if they were to share the same rpc pipe to
> communicate with user space.

I'm inclined to agree but I'll defer this to Steve as the maintainer of nfs utils

Benny

> 
> Currently I have a simple implementation of 'osdlogind' coded up which
> borrows its design heavily from 'blkmapd' code. Please let me know what
> would be the preferred way to go about this. Thanks in advance for your
> inputs. 
> 
> Sachin Bhamare 
> Panasas Inc.
> 
> 
> _______________________________________________
> osd-dev mailing list
> osd-dev@open-osd.org
> http://mailman.open-osd.org/mailman/listinfo/osd-dev
