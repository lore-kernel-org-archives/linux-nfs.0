Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:3252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753726AbZLKRIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Dec 2009 12:08:51 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <1629BB1E-EB8B-478C-8170-60413A5140A2@netapp.com>
From: Andy Adamson <andros@netapp.com>
To: Tharindu Rukshan Bamunuarachchi <btharindu@gmail.com>
In-Reply-To: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: starting 90-second grace period
Date: Fri, 11 Dec 2009 12:08:29 -0500
References: <f5b5ebae0912110300t78ceb985oc7a21b20a3429a52@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

you can set the lease time, which is the grace period, by writing to

/proc/fs/nfsd/nfsv4leasetime

note that this file is only available after the nfsd module is loaded,  
and is only read by nfsd upon startup.

-->Andy

On Dec 11, 2009, at 6:00 AM, Tharindu Rukshan Bamunuarachchi wrote:

> hi all,
>
> Is there anyway to reduce or remove "90-second grace period" ?
>
> I could not find any configurable parameter.
>
> grace_time seems to be derived from user_lease_time & lease_time.
>
> what are the negative effects of changing *_lease_time ?
>
> cheers
> -- 
> Tharindu Rukshan Bamunuarachchi
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

