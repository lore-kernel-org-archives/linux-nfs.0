Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47352 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755701Ab3IKUOk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 16:14:40 -0400
Date: Wed, 11 Sep 2013 16:14:39 -0400
To: Emmanuel Florac <eflorac@intellique.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity: problem solved
Message-ID: <20130911201439.GA1462@fieldses.org>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
 <20130911171145.323f9b9e@harpe.intellique.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20130911171145.323f9b9e@harpe.intellique.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 11, 2013 at 05:11:45PM +0200, Emmanuel Florac wrote:
> Le Thu, 5 Sep 2013 19:18:00 +0200
> Emmanuel Florac <eflorac@intellique.com> écrivait:
> 
> > Any hint, idea, etc would be extremely welcome. Even some
> > debugging method less painful than digging through huge 
> > tcpdumps would be nice :)
> 
> I post this answer in the faint hope that it may avoid a long and
> painful week of testing to someone else :)
> 
> The problem comes from the virtual network adapter "Intel pro 1000"
> using the e1000e linux driver. The Intel hardware supports a MTU of
> 4078 max. On a physical machine, it will fail to set up a greater value
> with something like:
> 
> # ifconfig eth0 mtu 4079
> SIOCSIFMTU: Invalid argument
> 
> However the virtual e1000 from VMWare ESX silently accept any value;
> then it will mostly work, and fail in mysterious way and only with
> certain protocols (such as nfs).

Ah-hah!

Thanks for the followup.--b.

> 
> In the case of VMWare virtual machines, using a vmnet3 virtual network
> adapter works fine with a mtu of 9000 under NFS. Therefore the problem
> is solved.
> 
> For the sake of completeness and curiosity, I'll try and see what
> happens with a KVM e1000 virtual device.
> 
> -- 
> ------------------------------------------------------------------------
> Emmanuel Florac     |   Direction technique
>                     |   Intellique
>                     |	<eflorac@intellique.com>
>                     |   +33 1 78 94 84 02
> ------------------------------------------------------------------------
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
