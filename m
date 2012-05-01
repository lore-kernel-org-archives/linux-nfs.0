Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41119 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754670Ab2EATdX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 15:33:23 -0400
Message-ID: <4FA03A77.8070404@RedHat.com>
Date: Tue, 01 May 2012 15:33:11 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/6] fix some problems with v4root handling in mountd
References: <20120424054003.20130.16209.stgit@notabene.brown>
In-Reply-To: <20120424054003.20130.16209.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/24/2012 01:46 AM, Neil Brown wrote:
> First I'd like to say that I love seeing comments that explain the
> code..  What way when the code does something different to the
> comment, I can be sure I'm on to something :-)
> 
> If I have exports:
> 
>  /  *(rw,no_root_squash)
>  /home 192.168.1.2(rw,no_root_squash)
> 
> Then I want to export 'root' to everything (on my side of a firewall)
> but '/home' only to one machine.
> However this doesn't work for host 192.168.1.2.
> If I try to mount '/' with NFSv3, it fails.
> If I try to mount '/' with NFSv4, then it works but we only see
> "home" in the mounted "/".
> 
> The problem is that the export of "/home" causes a V4ROOT export
> of "/" to be created for 192.168.1.2 and as MCL_SUBNETWORK comes
> before MCL_WILDCARD, the V4ROOT export wins and the other wildcard
> export isn't even tried.
> 
> So the following patches:
>  1/ fix the NFSv4 mount case so that we really see '/' and not a pseudo
>     '/'.  This is the case where the comment says the right thing
>     but the code doesn't.
> 
>  2/ fix 'mountd' lookup for NFSv2/v3 so they successfully mount
>     the real export, and don't fail because only the V4ROOT export
>     was found,
> 
>  3/ Fix a similar ordering problem in nfsd_fh.  Without this an
>     NFSv4 client might see the V4ROOT export for '/' rather than
>     the explicitly exported export.
> 
>  4/ Set a useful ttl on V4ROOT exports so they don't need to
>     constantly be refreshed, an
>   
>  5/ fix a buglet which didn't cause any of these problems but
>     certainly looks wrong.
Committed all 6... thanks!

steved.

> 
> Enjoy :-)
> 
> NeilBrown
> 
> ---
> 
> Neil Brown (6):
>       v4_root_add_parents: remove a possible buffer overflow.
>       v4root: set the time-to-live for V4ROOT exports to the DEFAULT.
>       v4set_root: force "fsid=0" for all exports of '/'
>       nfsd_fh: if two exports are possible, choose the one without V4ROOT
>       auth_authenticate_newcache: prefer non-V4ROOT export over V4ROOT exports.
>       lookup_export: really prefer nonV4ROOT exports.
> 
> 
>  utils/mountd/auth.c   |    7 +++----
>  utils/mountd/cache.c  |   21 +++++++++++++++++----
>  utils/mountd/v4root.c |   12 ++++++++++--
>  3 files changed, 30 insertions(+), 10 deletions(-)
> 
