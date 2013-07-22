Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:17709 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756932Ab3GVUQH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jul 2013 16:16:07 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH v1 07/19] NFS: Fix compiler warning in nfs_setup_sequence()
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1374519800.7972.20.camel@leira.trondhjem.org>
Date: Mon, 22 Jul 2013 16:16:01 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <3AAAEE1D-36BA-43FA-A37F-6CFD57314ADF@oracle.com>
References: <20130712155303.1444.62697.stgit@seurat.1015granger.net> <20130712163228.1444.26489.stgit@seurat.1015granger.net> <1374519800.7972.20.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 22, 2013, at 3:03 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Fri, 2013-07-12 at 12:32 -0400, Chuck Lever wrote:
>> Clean up.  Squelch compiler warning:
>> 
>> linux/fs/nfs/nfs4proc.c: In function ‘nfs4_setup_sequence’:
>> linux/fs/nfs/nfs4proc.c:703:2: warning: signed and unsigned type in
>> 	conditional expression [-Wsign-compare]
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfs/nfs4proc.c |    2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 7b2e008..5913e1d 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -655,7 +655,7 @@ static int nfs4_setup_sequence(const struct nfs_server *server,
>> 
>> 	dprintk("--> %s clp %p session %p sr_slot %d\n",
>> 		__func__, session->clp, session, res->sr_slot ?
>> -			res->sr_slot->slot_nr : -1);
>> +			(int)res->sr_slot->slot_nr : -1);
>> 
> 
> Please convert to make it unsigned, and to use NFS4_NO_SLOT instead of
> '-1'.

NFS4_NO_SLOT makes sense, but I'm not clear on "make it unsigned".

Leaving the format as "%d" allows NFS4_NO_SLOT to be displayed as "-1".  So, something like the following one-liner will address the compiler warning, and leave behavior unchanged:

-			res->sr_slot->slot_nr : -1);
+			res->sr_slot->slot_nr : NFS4_NO_SLOT);

That is, unless you prefer NFS4_NO_SLOT displayed in some other way?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




