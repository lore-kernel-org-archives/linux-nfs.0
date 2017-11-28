Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.nwra.com ([72.52.192.72]:57074 "EHLO mail.nwra.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751377AbdK1Or7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 28 Nov 2017 09:47:59 -0500
Received: from barry.cora.nwra.com (inferno.cora.nwra.com [208.187.183.84])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.nwra.com (Postfix) with ESMTPS id D9D6F3405F4
        for <linux-nfs@vger.kernel.org>; Tue, 28 Nov 2017 06:47:57 -0800 (PST)
Subject: Re: Strange NFS4 permission problem
From: Orion Poplawski <orion@nwra.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <c2dadd74-4981-5069-84f1-325ff2babd03@nwra.com>
Message-ID: <a21c58c0-29b2-5053-8ab9-0991a8e8610e@nwra.com>
Date: Tue, 28 Nov 2017 07:47:57 -0700
MIME-Version: 1.0
In-Reply-To: <c2dadd74-4981-5069-84f1-325ff2babd03@nwra.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/27/2017 04:28 PM, Orion Poplawski wrote:
> I have a kerberized NFS4 setup using EL7.4 that has been working for quite a
> long time.  Today I started having trouble with permissions from some clients.
>  I haven't been able to figure out what changed.
> 
> It appears though that some requests are being sent as root as so permission
> to access is denied.


This appears to be caused by BitDefender anti-virus.


-- 
Orion Poplawski
Manager of NWRA Technical Systems          720-772-5637
NWRA, Boulder/CoRA Office             FAX: 303-415-9702
3380 Mitchell Lane                       orion@nwra.com
Boulder, CO 80301                 https://www.nwra.com/
