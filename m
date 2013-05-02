Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40980 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759711Ab3EBNlb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 May 2013 09:41:31 -0400
Date: Thu, 2 May 2013 09:41:24 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Cc: linux-nfs@vger.kernel.org,
        Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Subject: Re: nfsd4: don't close read-write opens too soon
Message-ID: <20130502134123.GA14568@pad.fieldses.org>
References: <OF6EA99709.0488A876-ONC1257B5F.002A975B-C1257B5F.002B46BB@transmode.se>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF6EA99709.0488A876-ONC1257B5F.002A975B-C1257B5F.002B46BB@transmode.se>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 02, 2013 at 09:52:41AM +0200, Joakim Tjernlund wrote:
> We had the same problem as Toralf on 3.4.41 twice in a week now. After 
> searching the net we found: 
>   
> http://git.linux-nfs.org/?p=bfields/linux.git;a=commit;h=0c7c3e67ab91ec6caa44bdf1fc89a48012ceb0c5
> This seems to be the fix for our problem too but it is just sitting and 
> waiting?
> 
> As this bug brings the NFS server into a PANIC I figured the fix would be 
> rushed into Linus and stable trees
> but I cannot find it there.

I've got it queued up for 3.10.  Probably I'll send Linus the pull
request with that stuff tomorrow, and then it should start going to
stable trees some time thereafter.

Yeah, I probably should have submitted it before 3.9.

--b.
