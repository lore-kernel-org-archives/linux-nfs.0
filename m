Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm22.bullet.mail.sp2.yahoo.com ([98.139.91.92]:27968 "HELO
	nm22.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753215Ab1HDBdD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 21:33:03 -0400
Message-ID: <1312421581.87354.YahooMailNeo@web39805.mail.mud.yahoo.com>
Date: Wed, 3 Aug 2011 18:33:01 -0700 (PDT)
From: Vinay Venkataraghavan <raghavanvinay@yahoo.com>
Reply-To: Vinay Venkataraghavan <raghavanvinay@yahoo.com>
Subject: NFS root squash option
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello everybody,

I've run into a problem regarding exporting a share on linux with the root_squash option set. The problem is that on the client side I mount this share as root but the process I'd like to expose some files to run as root.

But since the root_squash option is set, the process running as root, does not have access to the file. 

Is there anyway around this problem. 


What I'd like to achieve is be able to have this process running as root be able to access the files on this share. Any help in this matter would be greatly appreciated. I've been scouring the web and the man pages etc and have come up with nothing.

I do have a few ideas:

1. Is it possible to mount the share providing the userid which is allowed to access the shares? If so how do I set this up as I can't find any options in the linux mount command.

2. Is it possible that I could add this process to some group which has permissions to access the files on this share. And then subsequently setup the nfs server side to be able to provide access to users in this group id?

Thanks in advance.
- Vinay
