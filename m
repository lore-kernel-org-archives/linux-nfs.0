Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:65333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753004Ab3BUXNm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 18:13:42 -0500
Message-ID: <5126AA24.5070908@RedHat.com>
Date: Thu, 21 Feb 2013 18:13:40 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/2] NFSv4.2: Added NFS v4.2 support to the NFS client
References: <1361484911-17537-1-git-send-email-steved@redhat.com>  <1361484911-17537-2-git-send-email-steved@redhat.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9235DAEC7@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9235DAEC7@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 21/02/13 17:22, Myklebust, Trond wrote:
> On Thu, 2013-02-21 at 17:15 -0500, Steve Dickson wrote:
>> > This enable NFSv4.2 support. To enable this code the
>> > CONFIG_NFS_V4_2 Kconfig define needs to be set and
>> > the -o v4.2 mount option need to be used.
>> > 
>> > Signed-off-by: Steve Dickson <steved@redhat.com>
>> > ---
>> >  fs/nfs/Kconfig       | 11 ++++++++++-
>> >  fs/nfs/callback.c    |  3 +++
>> >  fs/nfs/nfs4client.c  |  5 +++++
>> >  fs/nfs/nfs4proc.c    |  3 +++
>> >  fs/nfs/super.c       |  7 ++++++-
>> >  include/linux/nfs4.h |  4 ++++
>> >  6 files changed, 31 insertions(+), 2 deletions(-)
>> > 
>> > diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
>> > index 3861a1f..247db6d 100644
>> > --- a/fs/nfs/Kconfig
>> > +++ b/fs/nfs/Kconfig
>> > @@ -104,6 +104,15 @@ config NFS_V4_1
>> >  
>> >  	  If unsure, say N.
>> >  
>> > +config NFS_V4_2
>> > +	bool "NFS client support for NFSv4.2"
>> > +	depends on NFS_V4_1
>> > +	help
>> > +	  This option enables support for minor version 1 of the NFSv4 protocol
>> > +	  (RFC 5661) in the kernel's NFS client.
>> > +
>> > +	  If unsure, say N.
>> > +
>> >  config PNFS_FILE_LAYOUT
>> >  	tristate
>> >  	depends on NFS_V4_1
>> > @@ -133,7 +142,7 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
>> >  
>> >  config NFS_V4_SECURITY_LABEL
>> >  	bool "Provide Security Label support for NFSv4 client"
>> > -	depends on NFS_V4 && SECURITY
>> > +	depends on NFS_V4_2 && SECURITY
>> >  	help
> Just have NFS_V4_SECURITY_LABEL be automatically selected by NFS_V4_2.
> Requiring users to manually select both makes little sense...
> 
> 
Yeah... that make sense... 

steved.
