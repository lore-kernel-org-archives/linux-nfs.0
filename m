Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53294
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752237Ab0I1Rk1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Sep 2010 13:40:27 -0400
Date: Tue, 28 Sep 2010 10:40:47 -0700 (PDT)
Message-Id: <20100928.104047.104076408.davem@davemloft.net>
To: xemul@parallels.com
Cc: Trond.Myklebust@netapp.com, bfields@fieldses.org, chuck.lever@oracle.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/8] net: Export __sock_create
From: David Miller <davem@davemloft.net>
In-Reply-To: <4CA09F03.6090407@parallels.com>
References: <4CA06D62.4040703@parallels.com>
	<1285594260.19362.40.camel@heimdal.trondhjem.org>
	<4CA09F03.6090407@parallels.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Pavel Emelyanov <xemul@parallels.com>
Date: Mon, 27 Sep 2010 17:41:23 +0400

> On 09/27/2010 05:31 PM, Trond Myklebust wrote:
>> On Mon, 2010-09-27 at 14:09 +0400, Pavel Emelyanov wrote:
>>> Can we can do it not through the Dave's tree?
>> 
>> I think we will still need Dave's approval for this. Either an Ack or a
>> signed-off-by. Linus will very likely yell at us and refuse to take the
>> patch if we don't.
> 
> OK, I then put Dave in Cc.
> 
> And a small background of the patch - I'm trying to make sunrpc layer work
> in net namespaces and in order to do this I need to turn existing calls to
> sock_create_kern() into __sock_create() to specify the net namespace the
> socket are to be created in.
> 
> Dave, can we go on with this, please? :)

This is fine:

Acked-by: David S. Miller <davem@davemloft.net>
