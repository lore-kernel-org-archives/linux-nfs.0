Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:42226 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755265AbaE2Jp0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2014 05:45:26 -0400
Received: from [24.144.107.66] (helo=[192.168.0.11])
	by elasmtp-masked.atl.sa.earthlink.net with esmtpa (Exim 4.67)
	(envelope-from <mrmazda@earthlink.net>)
	id 1Wpwtp-0000lB-BO
	for linux-nfs@vger.kernel.org; Thu, 29 May 2014 05:45:25 -0400
Message-ID: <538701B4.6030207@earthlink.net>
Date: Thu, 29 May 2014 05:45:24 -0400
From: Felix Miata <mrmazda@earthlink.net>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: system updating routinely umounts "manual" nfs mounts
References: <53823B52.2080201@earthlink.net> <20140527205527.GC32160@fieldses.org>
In-Reply-To: <20140527205527.GC32160@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014-05-27 16:55 (GMT-0400) J. Bruce Fields composed:

> On Sun, May 25, 2014 at 02:49:54PM -0400, Felix Miata wrote:

>> This has been happening here for several months or more in devel
>> distro versions Factory and IIRC Cauldron and Rawhide.

>> Maybe others' manual nfs mounts are more "manual" than mine are.
>> Mine are actually a group of noauto fstab entries I enable via
>> script when I want them active. All of my installations are on real
>> x86 hardware, some 32 and others 64 bit. I'm guessing what's going
>> on is systemd updates syncing /proc/mounts to fstab, oblivious to
>> the manual post-init mount processes having taken place, but this
>> certainly could be nfs evolutionary fallout or something else I know
>> nothing about. Is this happening to others? Expected? My search of
>> nfs component @bugzilla.kernel.org produced nothing on apparent
>> point.

> The kernel certainly isn't going to unmount things for you like this, so
> this is a question for the distro or systemd maintainers or something.

Couldn't make it happen in Cauldron or Rawhide, so filed openSUSE bug:
https://bugzilla.novell.com/show_bug.cgi?id=880208
-- 
"The wise are known for their understanding, and pleasant
words are persuasive." Proverbs 16:21 (New Living Translation)

  Team OS/2 ** Reg. Linux User #211409 ** a11y rocks!

Felix Miata  ***  http://fm.no-ip.com/
