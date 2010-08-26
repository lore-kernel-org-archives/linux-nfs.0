Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:47704 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752145Ab0HZAMV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 20:12:21 -0400
Date: Wed, 25 Aug 2010 20:12:02 -0400
To: "Neil Brown" <neilb@suse.de>, "Peng Yu" <pengyu.ut@gmail.com>
Subject: Re: Does the machine need to be restarted after RPCNFSDCOUNT in /etc/default/nfs-kernel-server (ubuntu) is edited?
From: sfaibish <sfaibish@emc.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; format=flowed; delsp=yes; charset=iso-8859-15
References: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com> <20100826093648.26d03c1c@notabene>
Message-ID: <op.vh0qucfsunckof@usensfaibisl2e.eng.emc.com>
In-Reply-To: <20100826093648.26d03c1c@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 25 Aug 2010 19:36:48 -0400, Neil Brown <neilb@suse.de> wrote:

> On Wed, 25 Aug 2010 15:02:14 -0500
> Peng Yu <pengyu.ut@gmail.com> wrote:
>
>> Hi,
>>
>> I changed the value of RPCNFSDCOUNT in /etc/default/nfs-kernel-server
>> (ubuntu). Do I need to restart the machine?
>>
>> Or I need to restart nfsd? If so, would you please let me know how to
>> restart nfsd?
>>
>
> Easiest thing to do is simply
>
>    rpc.nfsd $NUMBER
>
> it will change the number of running threads to match the number that you
> give.
You still need to stop and restart the nfs for this to take effect.

/Sorin

>
> NeilBrown
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
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
