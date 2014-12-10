Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51840 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831AbaLJOUw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2014 09:20:52 -0500
To: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 00/19] gssd improvements
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 10 Dec 2014 15:20:51 +0100
From: =?UTF-8?Q?David_H=C3=A4rdeman?= <david@hardeman.nu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <54876612.50503@RedHat.com>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
 <548725DF.9000202@RedHat.com> <20141209202239.GB31849@hardeman.nu>
 <54876612.50503@RedHat.com>
Message-ID: <2b987f470a37844bd583365a1fa775e0@hardeman.nu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014-12-09 22:13, Steve Dickson wrote:
> On 12/09/2014 03:22 PM, David Härdeman wrote:
>> Agreed. Though I believe regressions would be noticed rather
>> quickly...and the ensuing screams would be rather loud? I might be
>> mistaken though...
> 
> Yeah... They will be screaming at me! not you... 8-)

Heh, yeah, but my point was rather that any problem will (hopefully) be 
spotted and reported rather quickly.

>>> Finally, why the "change dnotify to inotify" a good thing?

I was mostly referring to the EINTR thing...since dnotify is signal 
based, there are a lot of functions that should be checked for EINTR and 
restarted. Maybe they should anyway, but the need is less urgent with 
inotify (the other advantages were the reduced number of fds and not 
having to rescan the while rpc_pipefs hierarchy on every change).


