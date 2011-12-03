Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:63904 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752834Ab1LCQvZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 3 Dec 2011 11:51:25 -0500
Message-ID: <4EDA5387.5070103@RedHat.com>
Date: Sat, 03 Dec 2011 11:51:19 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Harald Dunkel <harri@afaics.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 fsid=0 export still necessary?
References: <4EDA0650.9080702@afaics.de>
In-Reply-To: <4EDA0650.9080702@afaics.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/03/2011 06:21 AM, Harald Dunkel wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
> 
> Hi folks,
> 
> several NFSv4-HOWTOs in the net require to export a root directory
> with fsid=0 first. Other exported directory trees should be nested
> within this root directory and exported with nohide. AFAIU the advan-
> tage of the root dir is that the client can mount "server:/somedir"
> instead of "server:/remote_mount_point/somedir".
> 
> Question: Is the common root directory optional? Since NFSv3 doesn't
> support this name space feature, wouldn't it be more wise to omit
> the root directory?
No, the fsid=0 export option is no longer necessary to make v4
exports compatible with v2/v3 exports. When the fsid option
is not set, the default root is define as "/" which allows
the v4 clients to mount the same exports as does the v2/v3 clients.

Now if you do not what "/" as your default root, you can
set fsid to something like fsid=/export. This will
change to default root to the /export directory which
means your v4 clients will only be able to access exports
under the /export directory. 

I believe the Linux server is the only server to have
this option...

steved.

> 
> 
> Any helpful comment would be highly appreciated
> 
> Harri
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.11 (GNU/Linux)
> 
> iEYEARECAAYFAk7aBlAACgkQUTlbRTxpHjeO0wCggdEdfcBzswibHAOG6w2xJa5r
> B4QAn3MsYZR7xCh60c1X4AsNLnutXSPI
> =nEBr
> -----END PGP SIGNATURE-----
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
