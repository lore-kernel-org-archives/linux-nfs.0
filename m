Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:36077 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbaF3NVE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jun 2014 09:21:04 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jun 2014 09:21:03 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4504038C803B
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 09:21:01 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5UDKxRn5833004
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 13:21:00 GMT
Received: from d01av01.pok.ibm.com (localhost [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5UDKwAX011128
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 09:20:59 -0400
Date: Mon, 30 Jun 2014 08:20:57 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: Richard Thornton <richie.thornton@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS working but I have unwanted 500MB quota
Message-ID: <20140630132057.GA26132@us.ibm.com>
References: <CA++rrJoQG76ag2gTBo6nA3s1nM1gVNoGR4+8YuzA6yjJqMufBQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA++rrJoQG76ag2gTBo6nA3s1nM1gVNoGR4+8YuzA6yjJqMufBQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Richard Thornton [richie.thornton@gmail.com] wrote:
> Hi,
> 
> Can somebody help please.
> 
> I setup NFS between two Ubuntu 14.04 systems and I can save files to
> the server but I have a 500MB quota I never setup (The btrfs partition
> has 1TB remaining but I can see I have only 500MB remaining on the
> directory, trying to copy anything larger gives an error), I would
> like to permanently remove the quota but can't seem to find the right
> info and commands.

You need help with btrfs here. quota will be managed by btrfs, not NFS.

Regards, Malahal.

> I used this page as a reference
> https://help.ubuntu.com/community/SettingUpNFSHowTo.
> 
> While trying to figure the quota issue out, I installed "quota" but
> haven't had any luck with the quota, repquota, edquota, quotacheck,
> setquota commands...very confusing.
> 
> Googling has given me nothing.
> 
> Thanks for taking a look.
> 
> Cheers
> Richard
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

