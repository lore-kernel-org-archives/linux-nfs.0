Return-Path: linux-nfs-owner@vger.kernel.org
Received: from shiva144.upmc.fr ([134.157.0.144]:55655 "EHLO shiva.upmc.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751284Ab2FWRi0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 Jun 2012 13:38:26 -0400
Message-ID: <4FE5FF08.1070802@upmc.fr>
Date: Sat, 23 Jun 2012 19:38:16 +0200
From: Bernard Pidoux <bernard.pidoux@upmc.fr>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Francois Romieu <romieu@fr.zoreil.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: rpc_pipefs kernel panic kernel 3.4.3
References: <F77FADB4-0415-4945-AC03-CEE36F2FEB08@upmc.fr>  <4FE4DB31.4000601@free.fr> <4FE4F7FA.4000604@free.fr>  <20120623061353.GA18625@electric-eye.fr.zoreil.com> <1340469281.3282.1.camel@lade.trondhjem.org>
In-Reply-To: <1340469281.3282.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Congratulation Trond !
Your patch did cure the kernel panic issue.
Many thanks.

Bernard

On 23/06/2012 18:34, Myklebust, Trond wrote:
> On Sat, 2012-06-23 at 08:13 +0200, Francois Romieu wrote:
>> (redirected from l-k, see http://marc.info/?l=linux-kernel&m=134040598419594&w=2)
>>
>> Bernard Pidoux <bernard.pidoux@free.fr> :
>> [rpc_pipefs_event panic with 3.4.4 at boot mount, 3.3.8 is fine]
>>
>> Should Bernard try a git bisect ?
>>
>
> Can you please see if commit 4697bd5e9419348ef9fa9b55cefe4355ad9d3d01
> (NFSv4: Fix a race in the net namespace mount notification) fixes the
> issue for you?
>
> Cheers
>    Trond
>

