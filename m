Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:59491 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754039Ab1A1TKc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Jan 2011 14:10:32 -0500
Subject: Re: [PATCH 2/2] NFS: NFSv4 readdir loses entries
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1296240348.5464.20.camel@heimdal.trondhjem.org>
Date: Fri, 28 Jan 2011 14:09:25 -0500
Cc: Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Message-Id: <F2D9DF83-FC13-400B-B1FE-4107AD35DCF1@oracle.com>
References: <20110128173624.3235.74504.stgit@matisse.1015granger.net> <20110128174105.3235.21014.stgit@matisse.1015granger.net> <4D430DFA.90708@netapp.com> <1296240348.5464.20.camel@heimdal.trondhjem.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 28, 2011, at 1:45 PM, Trond Myklebust wrote:

> On Fri, 2011-01-28 at 13:42 -0500, Bryan Schumaker wrote: 
>> On 01/28/2011 12:41 PM, Chuck Lever wrote:
>>> On recent 2.6.38-rc kernels, connectathon basic test 6 fails on
>>> NFSv4 mounts of OpenSolaris with something like:
>>> 
>>>> ./test6: readdir
>>>> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.12' dir entry, pass 0
>>>> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.82' dir entry, pass 0
>>>> 	./test6: (/mnt/klimt/matisse.test) didn't read expected 'file.164' dir entry, pass 0
>>>> 	./test6: (/mnt/klimt/matisse.test) Test failed with 3 errors
>>>> basic tests failed
>>>> Tests failed, leaving /mnt/klimt mounted
>>>> [cel@matisse cthon04]$
>>> 
>>> I narrowed the problem down to nfs4_decode_direct() reporting that the
>> 
>> I'm guessing that should be nfs4_decode_dirent()?
> 
> I've fixed that up in the version I applied to the 'bugfixes' branch.

Thanks.  I make that typo nearly every time I type "decode_dirent".

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




