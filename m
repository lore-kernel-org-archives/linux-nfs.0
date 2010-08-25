Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:35926 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818Ab0HYXLa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 19:11:30 -0400
To: "Peng Yu" <pengyu.ut@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: Does the machine need to be restarted after RPCNFSDCOUNT in /etc/default/nfs-kernel-server (ubuntu) is edited?
From: sfaibish <sfaibish@emc.com>
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
References: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
Date: Wed, 25 Aug 2010 19:11:19 -0400
Message-ID: <op.vh0n05o0unckof@usensfaibisl2e.eng.emc.com>
In-Reply-To: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 25 Aug 2010 16:02:14 -0400, Peng Yu <pengyu.ut@gmail.com> wrote:

> Hi,
>
> I changed the value of RPCNFSDCOUNT in /etc/default/nfs-kernel-server
> (ubuntu). Do I need to restart the machine?
>
> Or I need to restart nfsd? If so, would you please let me know how to
restart service.

> restart nfsd?
Try this
/etc/init.d/nfs start


>



-- 
Best Regards

Sorin Faibish
Corporate Distinguished Engineer
Network Storage Group

         EMC²
where information lives

Phone: 508-435-1000 x 48545
Cellphone: 617-510-0422
Email : sfaibish@emc.com
