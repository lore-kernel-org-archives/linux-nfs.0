Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52546 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756207Ab0HCUH1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 16:07:27 -0400
Subject: Re: Kerberos auth Problem with nfs3/4
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <20100803190327.GA12391@gibson.comsick.at>
Date: Tue, 3 Aug 2010 16:07:02 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <DFDB8589-9FBB-49A6-A9FB-75A8ADC1F2B5@netapp.com>
References: <20100803190327.GA12391@gibson.comsick.at>
To: Michael Guntsche <mike@it-loops.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

So the macosx client mount succeeded because the sname=maru@COMSICK.AT was successfully mapped to a UID whereas the linux client mount failed because the sname=nfs/gibson.comsick.at@COMSICK.AT UID mapping failed (or hung as Bruce described).

-->Andy

On Aug 3, 2010, at 3:03 PM, Michael Guntsche wrote:

> Some more news,
> 
> I tried mounting the same export from a macosx client and it succeeded.
> There was a difference though when looking at the rpc.svcgssd output
> 
> rpc.svcgssd -vvf:
> =================
> leaving poll
> handling null request
> sname = maru@COMSICK.AT
> DEBUG: serialize_krb5_ctx: lucid version!
> prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> doing downcall
> mech: krb5, hndl len: 4, ctx len 85, timeout: 1280897678 (35627 from now), clnt: <null>, uid: 1000, gid: 1000, num aux grps: 8:
>  (   1) 1000
>  (   2) 20
>  (   3) 24
>  (   4) 25
>  (   5) 29
>  (   6) 44
>  (   7) 46
>  (   8) 118
> sending null reply
> finished handling null request
> entering poll
> leaving poll
> handling null request
> sname = maru@COMSICK.AT
> DEBUG: serialize_krb5_ctx: lucid version!
> prepare_krb5_rfc1964_buffer: serializing keys with enctype 4 and length 8
> doing downcall
> mech: krb5, hndl len: 4, ctx len 85, timeout: 1280897678 (35627 from now), clnt: <null>, uid: 1000, gid: 1000, num aux grps: 8:
>  (   1) 1000
>  (   2) 20
>  (   3) 24
>  (   4) 25
>  (   5) 29
>  (   6) 44
>  (   7) 46
>  (   8) 118
> sending null reply
> finished handling null request
> 
> As you can see it uses a different sname and there are two requests, while I only see one with the linux client. Of course uid and gid are different too.
> 
> Kind regards,
> Michael
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

