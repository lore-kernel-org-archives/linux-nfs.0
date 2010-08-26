Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:53296 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752502Ab0HZL7R convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Aug 2010 07:59:17 -0400
Received: by wwb28 with SMTP id 28so1550023wwb.1
        for <linux-nfs@vger.kernel.org>; Thu, 26 Aug 2010 04:59:16 -0700 (PDT)
In-Reply-To: <20100826093648.26d03c1c@notabene>
References: <AANLkTi=8rnEtOikhVqsH5Pj1QUhc5MiSHMfncZO1xCem@mail.gmail.com>
	<20100826093648.26d03c1c@notabene>
Date: Thu, 26 Aug 2010 06:59:16 -0500
Message-ID: <AANLkTincnCeQYi6fvbEHLqqz+gYp0_ETdPAq6QebOxDg@mail.gmail.com>
Subject: Re: Does the machine need to be restarted after RPCNFSDCOUNT in
 /etc/default/nfs-kernel-server (ubuntu) is edited?
From: Peng Yu <pengyu.ut@gmail.com>
To: Neil Brown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 25, 2010 at 6:36 PM, Neil Brown <neilb@suse.de> wrote:
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
>   rpc.nfsd $NUMBER
>
> it will change the number of running threads to match the number that you
> give.

This will change the number in /etc/default/nfs-kernel-server? Or it
will not, meaning if I reboot machine, there will still be an old
number of nfsd running?

-- 
Regards,
Peng
