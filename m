Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.isti.cnr.it ([194.119.192.4]:1627 "EHLO mx2.isti.cnr.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751422Ab0K2Sjl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 13:39:41 -0500
Received: from SCRIPT-SPFWL-DAEMON.mx.isti.cnr.it by mx.isti.cnr.it
 (PMDF V6.5 #31825) id <01NUU9CJKVLSLKR7U0@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Mon, 29 Nov 2010 19:38:33 +0100 (MET)
Received: from conversionlocal.isti.cnr.it by mx.isti.cnr.it (PMDF V6.5 #31825)
 id <01NUU9CIV1YOLKRFUR@mx.isti.cnr.it> for linux-nfs@vger.kernel.org; Mon,
 29 Nov 2010 19:38:31 +0100 (MET)
Received: from [192.168.7.52] (firewall.itb.cnr.it [155.253.6.254])
 by mx.isti.cnr.it (PMDF V6.5 #31826)
 with ESMTPSA id <01NUU9CITX14LPP8E4@mx.isti.cnr.it> for
 linux-nfs@vger.kernel.org; Mon, 29 Nov 2010 19:38:31 +0100 (MET)
Date: Mon, 29 Nov 2010 19:38:30 +0100
From: Spelic <spelic@shiftmail.org>
Subject: Re: NFSv4 behaviour on unknown users
In-reply-to: <1291054975.12784.17.camel@heimdal.trondhjem.org>
To: linux-nfs@vger.kernel.org
Message-id: <4CF3F326.4060608@shiftmail.org>
Content-type: text/plain; format=flowed; charset=UTF-8
References: <4CF3ED05.3070401@shiftmail.org>
 <1291054975.12784.17.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 11/29/2010 07:22 PM, Trond Myklebust wrote:
> On Mon, 2010-11-29 at 19:12 +0100, Spelic wrote:
>    
> No. That is not allowed by the spec.
>
> Trond
>    

Too bad!! :-((
Was that spec decision really wise? :-/


BTW:
I've just noticed two discussions dated a few months ago in this ML 
regarding this.
the thread named 'numeric UIDs'
and more interestingly the thread: "Teach clients to map numeric strings 
into valid uids and gids."
http://marc.info/?t=128207393000001&r=1&w=2

Would the patch by Steve Dickson allow us to have numeric UID mapping 
like in NFSv3?
(Including ability for a non-squashed-root to do chown towards an UID 
which is unknown at server side)

And if yes, how come this is not against the specs?

Thank you
