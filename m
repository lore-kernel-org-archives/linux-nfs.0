Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751777AbbGNOcO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 10:32:14 -0400
Message-ID: <55A51D6C.2010802@RedHat.com>
Date: Tue, 14 Jul 2015 10:32:12 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Calvin Walton <calvin.walton@kepstin.ca>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca> <1429638223-13852-1-git-send-email-calvin.walton@kepstin.ca>
In-Reply-To: <1429638223-13852-1-git-send-email-calvin.walton@kepstin.ca>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Calivn,

I'm finally getting back to take a look at this...

On 04/21/2015 01:43 PM, Calvin Walton wrote:
> The systemd unit files now include the correct full paths to the
> executables when nfs-utils is configured with an alternate value
> for e.g. --prefix or --sbindir
> 
> Signed-off-by: Calvin Walton <calvin.walton@kepstin.ca>
> ---
> 
> Resend of the same patch, but this time generated with -M so the diff
> includes file moves; this should make it a bit easier to review.
I see what your are trying to do... Make the systemd scripts
use @sbindir@ instead of a hard coded '/usr/sbin/' which 
is fine. To do this you are renaming all the systemd 
scripts to .in systemd scripts. 

But what I'm missing is what actually generates the 
systemd scripts with the correct path names?

Since you took out the install-data-hook: rule from
the Makefile.am file, when I do a make install none
of the scripts get installed.... 

steved.
