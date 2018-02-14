Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:1819 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754470AbeBNHG1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Feb 2018 02:06:27 -0500
Subject: Re: running NFS in LXC
To: Benjamin Coddington <bcodding@redhat.com>
Cc: linux-nfs@vger.kernel.org
References: <5cedd413-81eb-6921-47bc-3c56e56d530a@aixigo.de>
 <6860CF8E-9790-4456-82D3-86A6A29E90BE@redhat.com>
From: Harald Dunkel <harald.dunkel@aixigo.de>
Message-ID: <8af7b137-0698-0c12-abc5-1cdd86c53a91@aixigo.de>
Date: Wed, 14 Feb 2018 08:06:25 +0100
MIME-Version: 1.0
In-Reply-To: <6860CF8E-9790-4456-82D3-86A6A29E90BE@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ben,

I take this as a "no serious problems by now". Good to hear.
Which kernel are you using?

I like your suggestion to use an (redundant?) iscsi server
instead of drbd, but I have to live with the current hardware.
Surely I will consider it for the next NFS server configuration.
On the other hand, drbd 8 has proven as rock-solid.


Regards
Harri
