Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:48836 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932944Ab2CZSoB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Mar 2012 14:44:01 -0400
Message-ID: <4F70B8DF.9000108@panasas.com>
Date: Mon, 26 Mar 2012 11:43:43 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Matt W. Benjamin" <matt@linuxbox.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: unlink within an open directory stream
References: <275611967.8.1332608027370.JavaMail.root@thunderbeast.private.linuxbox.com>  <1332609149.25346.12.camel@lade.trondhjem.org>  <4F70B2AE.4000504@panasas.com> <1332786347.17253.33.camel@lade.trondhjem.org>
In-Reply-To: <1332786347.17253.33.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/26/2012 11:25 AM, Myklebust, Trond wrote:

> On Mon, 2012-03-26 at 11:17 -0700, Boaz Harrosh wrote:
>> On 03/24/2012 10:12 AM, Myklebust, Trond wrote:
>>
>>
>> It's the new (post RHEL 6.0 Kernel) NFS need for opendir after an unlink.
> 
> What?
> 


The links below report on regression in RHEL 6.2 which have a new NFS
implementation where  6.0 used to be fine.
(Or it's what I understood from the reporters)

<snip>

> 

> No.
> 
> If the server supports permanent readdir cookies, then there is no need
> for opendir after unlink.
> 
> If the server does not have permanent readdir cookies, then our client
> has never supported it anyway (nor will it ever do so). That whole
> 'cookieverf' READDIR bullshit has never provided a workable model for a
> POSIX client...


Thanks Trond for the explanation. Forgive my slowness. So you are
saying that with knfsd it's actually filesystem dependent and maybe
the reporters did not compare apples-to-apples and the difference is
in the behind file system.

Matt I'm sure Trond is right with regard to Ganesha, because we
send a readdir index and a cookieverf, which will change after
unlink. Since the application does not call opendir again the
client will send the old cookies, which is now a different file
or might get out-of-bounds for Ganesha.

Let me think about it a bit. I'm sure we can send a Better
64bit cookie, which will be more persistent, even across unlinks.

> 
> 


Thanks
Boaz
