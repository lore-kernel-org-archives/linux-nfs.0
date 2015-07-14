Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59596 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014AbbGNPgg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2015 11:36:36 -0400
Message-ID: <55A52C83.7040501@RedHat.com>
Date: Tue, 14 Jul 2015 11:36:35 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Calvin Walton <calvin.walton@kepstin.ca>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: Substitute sbindir in systemd unit files.
References: <1429638029-13637-1-git-send-email-calvin.walton@kepstin.ca>	 <1429638223-13852-1-git-send-email-calvin.walton@kepstin.ca>	 <55A51D6C.2010802@RedHat.com> <1436887369.25203.12.camel@kepstin.ca>
In-Reply-To: <1436887369.25203.12.camel@kepstin.ca>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 07/14/2015 11:22 AM, Calvin Walton wrote:
> On Tue, 2015-07-14 at 10:32 -0400, Steve Dickson wrote:
>> Hello Calivn,
>>
>> I'm finally getting back to take a look at this...
>>
>> I see what your are trying to do... Make the systemd scripts
>> use @sbindir@ instead of a hard coded '/usr/sbin/' which 
>> is fine. To do this you are renaming all the systemd 
>> scripts to .in systemd scripts. 
> 
> Not all of them, there's a few I left untouched because they didn't
> need any directory substitutions.
> 
>> But what I'm missing is what actually generates the 
>> systemd scripts with the correct path names?
> 
> At the bottom of the systemd/Makefile.am file, a rule is added to
> generate a ".service" file from a ".service.in" file, which gets called
> automatically by make to generate the files listed in the unit_DATA
> variable.
> 
>> Since you took out the install-data-hook: rule from
>> the Makefile.am file, when I do a make install none
>> of the scripts get installed.... 
> 
> Hmm. I took a look at this; the files don't get installed unless you
> pass "--with-systemd=/usr/lib/systemd/system" (or the equivalent path
> on your system). In particular, using "--with-systemd" with no
> parameter won't work, since they'll get installed to the directory
> "yes" (i.e. the value of the --with-systemd parameter).
I see this... using --with-systemd does get the files created
and installed. 

> 
> This is the same behaviour as before my patch, but it could be improved
> by reworking the configure script a bit (in particular, using pkg
> -config to ask for the system default systemd unit directory).
It would be nice if the files got created and install by 
default (aka not having to specify --with-systemd) and 
not created/install when --without-systemd is used (which
does happen now).

> 
> Do you still want the patches split up between the Makefile changes and
> each individual modified unit file?
> 
No I'm good... just fix the default part and re-post... 

tia!

steved
