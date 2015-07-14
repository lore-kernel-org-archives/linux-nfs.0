Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:36252 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbbGNPWw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 11:22:52 -0400
Received: by ieik3 with SMTP id k3so13724716iei.3
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2015 08:22:51 -0700 (PDT)
Message-ID: <1436887369.25203.12.camel@kepstin.ca>
Subject: Re: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
From: Calvin Walton <calvin.walton@kepstin.ca>
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Date: Tue, 14 Jul 2015 11:22:49 -0400
In-Reply-To: <55A51D6C.2010802@RedHat.com>
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
	 <1429638223-13852-1-git-send-email-calvin.walton@kepstin.ca>
	 <55A51D6C.2010802@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2015-07-14 at 10:32 -0400, Steve Dickson wrote:
> Hello Calivn,
> 
> I'm finally getting back to take a look at this...
> 
> I see what your are trying to do... Make the systemd scripts
> use @sbindir@ instead of a hard coded '/usr/sbin/' which 
> is fine. To do this you are renaming all the systemd 
> scripts to .in systemd scripts. 

Not all of them, there's a few I left untouched because they didn't
need any directory substitutions.

> But what I'm missing is what actually generates the 
> systemd scripts with the correct path names?

At the bottom of the systemd/Makefile.am file, a rule is added to
generate a ".service" file from a ".service.in" file, which gets called
automatically by make to generate the files listed in the unit_DATA
variable.

> Since you took out the install-data-hook: rule from
> the Makefile.am file, when I do a make install none
> of the scripts get installed.... 

Hmm. I took a look at this; the files don't get installed unless you
pass "--with-systemd=/usr/lib/systemd/system" (or the equivalent path
on your system). In particular, using "--with-systemd" with no
parameter won't work, since they'll get installed to the directory
"yes" (i.e. the value of the --with-systemd parameter).

This is the same behaviour as before my patch, but it could be improved
by reworking the configure script a bit (in particular, using pkg
-config to ask for the system default systemd unit directory).

Do you still want the patches split up between the Makefile changes and
each individual modified unit file?

-- 
Calvin Walton <calvin.walton@kepstin.ca>
