Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6089 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933531Ab0FRO6G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jun 2010 10:58:06 -0400
Message-ID: <4C1B8985.8090808@panasas.com>
Date: Fri, 18 Jun 2010 10:58:13 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: "Smets, Jan (Jan)" <jan.smets@alcatel-lucent.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4.1 status
References: <14C7F4F06DB5814AB0DE29716C4F6D670B6534E7@FRMRSSXCHMBSB1.dc-m.alcatel-lucent.com>
In-Reply-To: <14C7F4F06DB5814AB0DE29716C4F6D670B6534E7@FRMRSSXCHMBSB1.dc-m.alcatel-lucent.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jun. 16, 2010, 21:05 -0400, "Smets, Jan (Jan)" <jan.smets@alcatel-lucent.com> wrote:
> Hi list
> 
> I would like to know what status the NFS 4.1 (pNFS) development is in. 

Hi Jan,

Our main focus in development right now is submitting basic implementation for the pnfs files layout
and continuing to improve also the object and block layout implementations that will follow.

> 
> Can it be tested? If yes, is there any guide what exactly I can do with it at this stage (and how) ? 

The guides are placed on our wiki:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_prototype_design

> I already have the pnfs capable kernel, but it's unclear to me what userland tools I need (server side).

What are you testing on the back end?

> 
> At the end I would like multiple dataservers that stripe data, 

That should not be a problem.

> and multiple metadata servers that also stripe data and all with failover/redundancy/load balancing stuff. But maybe I'm whishing for too much, yet.

Yes, you're aiming too high at this point.
That said, contributing code to do all that will be truly appreciated! ;-)

Benny

> 
> Thanks
> 
>  - Jan
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
