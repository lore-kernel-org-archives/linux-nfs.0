Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:47744 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833Ab1IYFKo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Sep 2011 01:10:44 -0400
Received: by wyg34 with SMTP id 34so5021017wyg.19
        for <linux-nfs@vger.kernel.org>; Sat, 24 Sep 2011 22:10:43 -0700 (PDT)
Message-ID: <4E7EB7CE.5040502@tonian.com>
Date: Sun, 25 Sep 2011 08:10:38 +0300
From: Benny Halevy <bhalevy@tonian.com>
To: Steve Dickson <SteveD@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: ANNOUNCE: nfs-utils-1.2.5 released.
References: <4E7DD35D.9080800@RedHat.com>
In-Reply-To: <4E7DD35D.9080800@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve, I updated git://linux-nfs.org/~bhalevy/pnfs-nfs-utils
rebased onto 1.2.5.

It looks like you forgot to add/publish the tag nfs-utils-1-2-5.

Benny

On 2011-09-24 15:55, Steve Dickson wrote:
> New Features in this release:
> 
>    * With the addition of the blkmapd daemon, the client 
>      now supports every pNFS layout type. 
> 
>    * The usual assorted bug fixes. 
> 
> The tarball can only be found at Sourceforge.net since 
> master.kernel.org is still down:
> 
>   http://sourceforge.net/projects/nfs
> 
> [ Maybe we should start thinking about putting the rpms on linux-nfs.org?? ]
> 
> The git tree is at:
>    git://linux-nfs.org/nfs-utils
> 
> The change log is also only on Sourceforge.net:
> 
> http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.5/Changelog-1.2.5/download
> 
> steved.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
