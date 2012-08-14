Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54125 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab2HNA2p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 20:28:45 -0400
Message-ID: <50299BAA.40909@panasas.com>
Date: Tue, 14 Aug 2012 03:28:26 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>, Benny Halevy <bhalevy@tonian.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "Welch, Brent" <welch@panasas.com>,
        Garth Gibson <garth.gibson@panasas.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>    <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>    <1344522979.23523.2.camel@lade.trondhjem.org>    <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com>   <1344526780.25447.6.camel@lade.trondhjem.org>   <5027E98B.7050603@panasas.com>  <4FA345DA4F4AE44899BD2B03EEEC2FA939C3E7@SACEXCMBX04-PRD.hq.netapp.com>  <50299041.2040302@panasas.com> <4FA345DA4F4AE44899BD2B03EEEC2FA93A064E@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93A064E@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/14/2012 03:16 AM, Myklebust, Trond wrote:

> 
> The client can't guarantee that. The protocol offers no way for it to do
> so, no matter what the pNFS text may choose to say.
> 


What? why not? all the client needs to do is stop sending bytes.
What is not guarantied? I completely do not understand what you
say. How stopping any sends does not guaranty that?

Please explain

Thanks
Boaz
 
