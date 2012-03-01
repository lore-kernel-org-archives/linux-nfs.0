Return-Path: linux-nfs-owner@vger.kernel.org
Received: from hawk.cora.nwra.com ([4.28.99.182]:52933 "EHLO
	hawk.cora.nwra.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758697Ab2CAPeR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Mar 2012 10:34:17 -0500
Message-ID: <4F4F96EA.9050203@cora.nwra.com>
Date: Thu, 01 Mar 2012 08:34:02 -0700
From: Orion Poplawski <orion@cora.nwra.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfs4 mount hanging suddenly
References: <4F4EA6D0.30606@cora.nwra.com>  <20120229231732.GD6506@fieldses.org> <4F4EB2FE.9040108@cora.nwra.com> <1330609841.6218.6.camel@lade.trondhjem.org>
In-Reply-To: <1330609841.6218.6.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/01/2012 06:50 AM, Myklebust, Trond wrote:
> On Wed, 2012-02-29 at 16:21 -0700, Orion Poplawski wrote:
>> On 02/29/2012 04:17 PM, J. Bruce Fields wrote:
>>> On Wed, Feb 29, 2012 at 03:29:36PM -0700, Orion Poplawski wrote:
OMP Reply (Call
>>>
>>> That probably means the server is waiting for the client to return a
>>> delegation.
>>>
>>> Either the server's confused about their being a delegation, or the
>>> client's failing to return one it should?
>>>
>
> As far as I can see from your trace, the client keeps trying to open the
> file '.history', and the server keeps replying with NFS4ERR_DELAY. There
> is nothing in the trace itself that can tell us why the server is
> delaying.

So, it seems to be on the server side?  I didn't get any relief 
restarting nfs on the server.  Any way to trace what is happening on the 
server side?

Thanks again.


-- 
Orion Poplawski
Technical Manager                     303-415-9701 x222
NWRA/CoRA Division                    FAX: 303-415-9702
3380 Mitchell Lane                  orion@cora.nwra.com
Boulder, CO 80301              http://www.cora.nwra.com
