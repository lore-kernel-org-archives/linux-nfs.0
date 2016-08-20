Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34508 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752961AbcHTRJa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 20 Aug 2016 13:09:30 -0400
Subject: Re: [PATCH 1/2] systemd: improve ordering between nfs-server and
 various mounts
To: NeilBrown <neilb@suse.com>
References: <147157095612.26568.14161646901346011334.stgit@noble>
 <147157115637.26568.2867884353016441810.stgit@noble>
 <ec72b2cf-90e5-d8f1-bf35-61ee8717a2e6@RedHat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Martin Pitt <martin.pitt@ubuntu.com>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <529265d4-2b63-aa4c-f1b1-ca27fb395be2@RedHat.com>
Date: Sat, 20 Aug 2016 13:09:01 -0400
MIME-Version: 1.0
In-Reply-To: <ec72b2cf-90e5-d8f1-bf35-61ee8717a2e6@RedHat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/20/2016 11:53 AM, Steve Dickson wrote:
>>  if INSTALL_SYSTEMD
>> > +genexec_PROGRAMS = nfs-server-generator
>> >  install-data-hook: $(unit_files)
>> >  	mkdir -p $(DESTDIR)/$(unitdir)
>> >  	cp $(unit_files) $(DESTDIR)/$(unitdir)
> These automake command are not  compiling or installing the generator... 
> I'm looking into it but I was just wondering how you tested this code,
> you compiled the code by hand?
My bad... it turns out INSTALL_SYSTEMD is not
defined by default... As soon as I enabled that
everything got compiled and installed.

steved.
