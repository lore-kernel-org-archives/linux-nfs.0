Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from sainfoin-out.extra.cea.fr ([132.166.172.107]:49426 "EHLO
	sainfoin-out.extra.cea.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754417Ab0FVHO2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jun 2010 03:14:28 -0400
Received: from pisaure.intra.cea.fr (pisaure.intra.cea.fr [132.166.88.21])
	by sainfoin.extra.cea.fr (8.14.2/8.14.2/CEAnet-Internet-out-2.0) with ESMTP id o5M7ERR7022835
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 22 Jun 2010 09:14:27 +0200
Received: from muguet1.intra.cea.fr (muguet1.intra.cea.fr [132.166.192.6])
	by pisaure.intra.cea.fr (8.14.4/8.14.4) with ESMTP id o5M7EQmE009963
	for <linux-nfs@vger.kernel.org>; Tue, 22 Jun 2010 09:14:27 +0200
	(envelope-from Philippe.DENIEL@CEA.FR)
Received: from zia.bruyeres.cea.fr (esteban.dam.intra.cea.fr [132.165.76.10])
	by muguet1.intra.cea.fr (8.13.8/8.13.8/CEAnet-Intranet-out-1.1) with SMTP id o5M7EQUq025092
	for <linux-nfs@vger.kernel.org>; Tue, 22 Jun 2010 09:14:26 +0200
Message-ID: <4C2062D2.8060309@cea.fr>
Date: Tue, 22 Jun 2010 09:14:26 +0200
From: DENIEL Philippe <philippe.deniel@cea.fr>
To: James Morris <jmorris@namei.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: RPCL source file for NFSv3 XATTR ?
References: <4C1F5041.4050408@cea.fr> <alpine.LRH.2.00.1006220921570.16648@tundra.namei.org>
In-Reply-To: <alpine.LRH.2.00.1006220921570.16648@tundra.namei.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

James Morris a écrit :
> On Mon, 21 Jun 2010, DENIEL Philippe wrote:
>
>   
>> I could quickly had the NFSv3 Xattr (with compatibility with James's
>> patches), I just have to implement the right additional NFSv3 functions.
>> In order to do this, I just need RPCL descriptions of the xattr
>> dedicated NFSv3 functions. Where could I find this ?
>>     
>
> There is no RPCL as yet -- it's on the todo list.
>   
In fact, I just need RPCL file to compile it into the related C 
structures and XDR functions. If you can provide me with such stuff (I 
am doing user space development, I am not sure the stuff from the kernel 
sources is actually useful to me), then I'll have enough material to 
start adding the feature to my product.

    Regards,

       Philippe
