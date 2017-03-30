Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39592 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933282AbdC3PBv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Mar 2017 11:01:51 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id A781C61D03
        for <linux-nfs@vger.kernel.org>; Thu, 30 Mar 2017 15:01:50 +0000 (UTC)
Subject: Re: [nfs-utils PATCH] systemd: add generators for the rpc_pipefs
 mountpoint
To: Scott Mayhew <smayhew@redhat.com>
References: <20170328133703.19325-1-smayhew@redhat.com>
 <2aace10d-1b9b-b8e8-4f85-caf31f5f51bf@RedHat.com>
 <20170329180207.xkcxepra442j6vv6@tonberry.usersys.redhat.com>
 <6a24bdf2-d94b-1a7d-5e2e-ceeefea3cc72@RedHat.com>
 <20170329225959.a5okdablgaanr64z@tonberry.usersys.redhat.com>
 <f0ff747b-9133-f218-22a0-ab425bb3faae@RedHat.com>
 <20170330130430.drzephsy2hljldpa@tonberry.usersys.redhat.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <dea05f84-d1d6-1f52-b79b-22f72dda053f@RedHat.com>
Date: Thu, 30 Mar 2017 11:01:49 -0400
MIME-Version: 1.0
In-Reply-To: <20170330130430.drzephsy2hljldpa@tonberry.usersys.redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 03/30/2017 09:04 AM, Scott Mayhew wrote:
>>> I've already boiled it down to one generator.  Does that make a
>>> difference?
>> I didn't know that... but still I would like to take any and all
>> opportunity to migrate things in one config file. 
> Okay, I'll move Pipefs-Directory and Cache-Expiration to nfs.conf.
It looks to me that the Cache-Expiration knob is just broken.
When the knob is set rpc.idmapd tries to open a file
   /proc/sys/fs/nfs/idmap_cache_timeout

That will only exist when the client does a mount, meaning
the file will never exist when server starts. 

Anybody have clue as to why this knob exists? 

The point being, Please leave the knob where it is (reading
from idmapd.conf) because I don't think we want to port 
broken knobs into nfs.conf.

steved.


 

