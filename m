Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:35057 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751723AbbKBNXy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Nov 2015 08:23:54 -0500
Received: by iofz202 with SMTP id z202so142947433iof.2
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2015 05:23:53 -0800 (PST)
Message-ID: <1446470630.8952.6.camel@kepstin.ca>
Subject: Re: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
From: Calvin Walton <calvin.walton@kepstin.ca>
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Date: Mon, 02 Nov 2015 08:23:50 -0500
In-Reply-To: <56375CD4.3010806@RedHat.com>
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>
	 <1429638223-13852-1-git-send-email-calvin.walton@kepstin.ca>
	 <56375CD4.3010806@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

On Mon, 2015-11-02 at 07:53 -0500, Steve Dickson wrote:
> Hello, 
> 
> I'm finally getting around to looking at this and
> I'm seen a couple issues...

> > -unit_dir = /usr/lib/systemd/system
> > -
> > -if INSTALL_SYSTEMD
> > -install-data-hook: $(unit_files)
> But after making the patch apply cleanly the scripts
> no longer get installed and I believe its 
> because you took out the above rule. 

You had actually ran into this same issue when you reviewed the patch
earlier. This rule isn't needed because automake's built-in install
path functionality is used - but the files only get installed if
  --with-systemd=/some/path
is passed to configure. (If you only use --with-systemd, you might find
the units get installed to the directory "/yes")

The conclusion was that some patching of configure was needed - it
should enable installing the unit files by default if systemd is found,
and not require manually specifying the path where to install the units
(using e.g. pkg-config to find it if unspecified)

I should have done this earlier, but was busy with some other stuff for
work.

I'm ok with autoconf stuff, so I'll take a look at rolling an updated
patch series with the configure changes. Hopefully it'll get done
before several months have passed...

-- 
Calvin Walton <calvin.walton@kepstin.ca>

