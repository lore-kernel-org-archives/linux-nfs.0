Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:60296 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751788Ab3FYToH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Jun 2013 15:44:07 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/3] NFSv4.1 Fix gdia_maxcount calculation to fit in
 ca_maxresponsesize
Date: Tue, 25 Jun 2013 19:44:06 +0000
Message-ID: <1B20F39A-B139-4A53-8B1F-2C0491FF0943@netapp.com>
References: <1372185454-1888-1-git-send-email-andros@netapp.com>
 <1372185454-1888-3-git-send-email-andros@netapp.com>
 <1372188518.5968.48.camel@leira.trondhjem.org>
In-Reply-To: <1372188518.5968.48.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 25, 2013, at 3:28 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com>
 wrote:

> On Tue, 2013-06-25 at 14:37 -0400, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>> 
>> The GETDEVICEINFO gdia_maxcount represents all of the data being returned
>> within the GETDEVICEINFO4resok structure and includes the XDR overhead.
>> 
>> The CREATE_SESSION ca_maxresponsesize is the maximum reply and includes the RPC
>> headers (including security flavor credentials and verifiers).
> 
> This still looks wrong.
> 
> The problem is that pdev->pglen is used both as the total buffer length,
> as a function argument and as the reply message length (through the call
> to xdr_init_decode_pages). We really should split out those 3 different
> roles…

Ah. OK, I'll split them out...

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com

