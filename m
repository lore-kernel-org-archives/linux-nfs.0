From: Tom Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>
Subject: Re: mount.nfs: access denied by server
Date: Tue, 25 Aug 2009 13:17:51 -0500
Message-ID: <4A942ACF.4030502@sun.com>
References: <31F3372A-891E-44EF-8DD2-78D5A3AD5CF1@oracle.com>
 <20090821200403.GA23529@fieldses.org>
 <EB232FA3-96EF-4332-94D5-61F465912838@oracle.com>
 <1250889345.5700.11.camel@heimdal.trondhjem.org>
 <20090821213016.GG23529@fieldses.org>
 <1250890836.5700.19.camel@heimdal.trondhjem.org>
 <20090821214720.GH23529@fieldses.org>
 <1250891463.5700.21.camel@heimdal.trondhjem.org>
 <20090824161004.GB4985@fieldses.org>
 <1251133618.6325.262.camel@heimdal.trondhjem.org>
 <20090824174129.GD4985@fieldses.org>
 <1EEDD90B-709F-4C78-97B4-6107AE100162@oracle.com> <4A94162C.20904@sun.com>
 <1251219492.25372.3.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>, nfs-discuss-xZgeD5Kw2fzokhkdeNNY6A@public.gmane.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-2.Sun.COM ([192.18.98.43]:64935 "EHLO
	brmea-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526AbZHYSSX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2009 14:18:23 -0400
Received: from fe-amer-10.sun.com ([192.18.109.80])
	by brmea-mail-2.sun.com (8.13.6+Sun/8.12.9) with ESMTP id n7PIIPdf026096
	for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2009 18:18:25 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KOY00M002LGGN00-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org> for linux-nfs@vger.kernel.org; Tue,
 25 Aug 2009 12:18:25 -0600 (MDT)
In-reply-to: <1251219492.25372.3.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2009-08-25 at 11:49 -0500, Tom Haynes wrote:
>   
>> With OpenSolaris NFSv3, there is no autonegotiation.  With NFSv4, we 
>> support the autonegotiation
>> as defined in the protocol.
>>
>> We just went through a regression with this algorithm.
>>     
>
> NFSv4 also allows the server to change the list of supported security
> flavours on the fly at any point in the namespace, and at any time. How
> does OpenSolaris currently deal with this?
>
>   

The client gets a WRONGSEC and then initiates auto-negotiation.

