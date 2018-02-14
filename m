Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:58530 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1030288AbeBNOPH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Feb 2018 09:15:07 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Harald Dunkel" <harald.dunkel@aixigo.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: running NFS in LXC
Date: Wed, 14 Feb 2018 09:15:05 -0500
Message-ID: <F9942544-0C31-4618-BF73-292FF4265C31@redhat.com>
In-Reply-To: <8af7b137-0698-0c12-abc5-1cdd86c53a91@aixigo.de>
References: <5cedd413-81eb-6921-47bc-3c56e56d530a@aixigo.de>
 <6860CF8E-9790-4456-82D3-86A6A29E90BE@redhat.com>
 <8af7b137-0698-0c12-abc5-1cdd86c53a91@aixigo.de>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 14 Feb 2018, at 2:06, Harald Dunkel wrote:

> Hi Ben,
>
> I take this as a "no serious problems by now". Good to hear.
> Which kernel are you using?

This was years ago on a 2.6.32 series.  I don't expect you'll have 
serious problems now, either.  As far as I know, my last employer is 
still using that architecture, but I couldn't tell you what software 
versions they're on now..

We moved to the knfsd-in-a-container from an architecture that was 
essentially a bunch of vanilla knfsds that could mount and any of the 
block devices, and block devices were tied to IP addresses, and this was 
all orchestrated by pacemaker.  The problem with that one was that when 
a block device or filesystem was migrated, the server receiving that 
filesystem had to be put into grace, which disrupted any existing NFS 
serving that was going on.

Test things, let us know how it works!

Ben
