Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:26169 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757687Ab1ANPwL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jan 2011 10:52:11 -0500
Subject: Re: 4.1 no-pnfs mount option?
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <20110114153846.GA21766@merit.edu>
Date: Fri, 14 Jan 2011 10:51:55 -0500
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
        linux-nfs@vger.kernel.org
Message-Id: <570A25CA-7C17-4F61-B004-04A2FC2D885D@netapp.com>
References: <20110114151945.GA21629@merit.edu> <AANLkTimSp6BTgk1YQonXd6HuVS-JEpQUWqsny7JymJsd@mail.gmail.com> <20110114153846.GA21766@merit.edu>
To: Jim Rees <rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 14, 2011, at 10:38 AM, Jim Rees wrote:

> William A. (Andy) Adamson wrote:
> 
>  No mount option - just configure your machine to not load any pnfs
>  layoutdriver modules.
> 
> That works, thanks, but I was hoping for a way to have layout and non-layout
> mounts going on at the same time.

I guess that means two clients.

-->Andy

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

