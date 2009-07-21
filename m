From: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 21:57:13 +0200
Message-ID: <200907212157.14781.elendil@planet.nl>
References: <4A64EB1F.4000602@candelatech.com> <1248178527.5222.0.camel@heimdal.trondhjem.org> <4A65F184.5060802@candelatech.com> <1248196339.21343.8.camel@heimdal.trondhjem.org> <4A65FCB2.6080903@candelatech.com> <1248199140.21343.17.camel@heimdal.trondhjem.org> <4A660295.9020807@candelatech.com> <1248200897.21343.19.camel@heimdal.trondhjem.org> <4A6609A9.3000504@candelatech.com> <4A6609A9.3000504@candelatech.com> <1248202462.21343.21.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Cc: greearb@candelatech.com, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from Cpsmtpm-eml107.kpnxchange.com ([195.121.3.11]:52005 "EHLO
	CPSMTPM-EML107.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751973AbZGUT5Q (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jul 2009 15:57:16 -0400
In-reply-To: <1248202462.21343.21.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> OK. Then the NFSv4.1 merge has screwed up the state management. We do
> NOT want to hold client id state on the server when there is no file
> state...

Hmm. I doubt that as I can reproduce the same problem (at least the mount 
hanging, not necessarily the errors) with .30, which I presume is before 
the merge.

I have seen the errors too, but that may have been with 2.6.31 (though 
definitely without NFS_V4_1). I seem unable to reproduce those with .30.

On the server (.30) in /etc/exportfs:
/srv/exports         10.19.66.0/24(rw,subtree_check,sync,mp,nohide)
/srv/exports/data    10.19.66.0/24(rw,subtree_check,sync,mp,nohide)

# exportfs
/srv/exports         10.19.66.0/24
/srv/exports/data    10.19.66.0/24

On the client (.30.2):
# mount thorin:/data /mnt -t nfs4
<hangs>

Cheers,
FJP
