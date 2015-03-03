Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757386AbbCCRKN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 12:10:13 -0500
Message-ID: <54F5EAF1.10205@RedHat.com>
Date: Tue, 03 Mar 2015 12:10:09 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Martin Pitt <martin.pitt@ubuntu.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] systemd: Relax dependencies of services
References: <20150303155010.GC3219@piware.de>
In-Reply-To: <20150303155010.GC3219@piware.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey 

On 03/03/2015 10:50 AM, Martin Pitt wrote:
> Hello all,
> 
> I would like to make NFS start earlier in the boot (i. e. before
> basic.target), so that you can do things like put /var/ on NFS, and
> rcS SysV init scripts which depend on $remote_fs work.
> 
> I tested this on both a server and a client.
> 
> Thanks for considering!
To make your two patch easier to review, could you mind
in-lining the patches in your email instead of attaching them
and then repost both patches?

See section 6 of https://www.kernel.org/doc/Documentation/SubmittingPatches
for details 

Being we are looking into monkey around with the systemd scripts
and changing the time of things I want make it as easy as 
possible to review. 

Finally could you also cc the systemd folks at
   systemd-devel@lists.freedesktop.org
when you repost the patches? 

tia!

steved.
