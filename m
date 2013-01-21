Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:36837 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273Ab3AURdE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 12:33:04 -0500
Message-ID: <50FD7BCB.4090001@candelatech.com>
Date: Mon, 21 Jan 2013 09:32:59 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Question on nfs40_discover_server_trunking.
References: <50F9BE66.6080608@candelatech.com>  <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com>  <1358546604.2872.6.camel@leira.trondhjem.org>  <4FA345DA4F4AE44899BD2B03EEEC2FA915C04FE5@sacexcmbx05-prd.hq.netapp.com>  <C11ACA70-EC3A-4FAD-8ADC-572F9B6B4CFE@oracle.com>  <1358556248.2835.10.camel@leira.trondhjem.org>  <4FA345DA4F4AE44899BD2B03EEEC2FA915C0721A@sacexcmbx05-prd.hq.netapp.com>  <A4F82546-02DA-4CB6-A2FB-D7A380E8D263@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA915C076CF@sacexcmbx05-prd.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA915C076CF@sacexcmbx05-prd.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/18/2013 08:11 PM, Myklebust, Trond wrote:

> The Oops is just a symptom. The underlying problem here is the client
> side spec violation.
>
> See attachments for the v3 patches...
>

I have been testing with these, and have not seen any NFS crashes since applying
them.

I still do see some crashes on tcp-recv, but these were there before, and may
not be related to NFS anyway.  I'll continue to debug the TCP crashes,
but as for these three NFS patches, feel free to add:

Tested-By:  Ben Greear <greearb@candelatech.com>

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

