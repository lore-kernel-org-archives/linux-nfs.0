From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 1/1] NFS: map nfs_probe_fsinfo errors
Date: Sun, 07 Dec 2008 11:00:56 +0200
Message-ID: <493B90C8.5000001@panasas.com>
References: <1228410550-17040-1-git-send-email-andros@netapp.com>	 <1228411011.7475.6.camel@heimdal.trondhjem.org>	 <1228411282.7475.9.camel@heimdal.trondhjem.org>	 <89c397150812041050u184afda7s2d33bc1aa82b8171@mail.gmail.com>	 <1228417616.7475.16.camel@heimdal.trondhjem.org>	 <89c397150812041116t74692ca1k5ce2ca87e64b5a2b@mail.gmail.com>	 <1228420665.7475.19.camel@heimdal.trondhjem.org>	 <89c397150812041231v4eeeb6a4y5106b7db9b53c037@mail.gmail.com> <1228424344.24870.0.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:18762 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751126AbYLGJBF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Dec 2008 04:01:05 -0500
In-Reply-To: <1228424344.24870.0.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Thu, 2008-12-04 at 15:31 -0500, William A. (Andy) Adamson wrote:
>> How about -EPROTONOSUPPORT?
> 
> That's definitely what you should return to the 'mount' command, but not
> to applications.

That should be possible if we deal with it differently in
nfs4_proc_sequence() and reclaimer().

Benny

> 
> Cheers
>   Trond
> 
>> On Thu, Dec 4, 2008 at 2:57 PM, Trond Myklebust
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Thu, 2008-12-04 at 14:16 -0500, William A. (Andy) Adamson wrote:
>>>>>> and the one that I saw when I tried to mount a v4.0 server with a v4.1
>>>>>> client which caused a segfault.
>>>>>>
>>>>>> NFS4ERR_MINOR_VERS_MISMATCH.
>>>>> Should never happen on a v4.0 client...
>>> Hmm...
>>>
>>> That said, it wouldn't harm to add the MINOR_VERS_MISMATCH error to
>>> nfs_errtbl[]. I suppose the only thing we can do is to map it to EIO,
>>> but that would be better than letting it slip through the cracks...
>>>
>>> --
>>> Trond Myklebust
>>> Linux NFS client maintainer
>>>
>>> NetApp
>>> Trond.Myklebust@netapp.com
>>> www.netapp.com
>>>

