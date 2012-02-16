Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:27581 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584Ab2BPUKE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 15:10:04 -0500
Subject: Re: [PATCH 01/13] NFS: Make nfs_cache_array.size a signed integer
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=windows-1252
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1329421931.4279.22.camel@lade.trondhjem.org>
Date: Thu, 16 Feb 2012 15:09:59 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <D241F385-D756-4C1D-9BA2-95478927CBE4@oracle.com>
References: <20120215213336.3254.98936.stgit@ellison.1015granger.net> <20120215213451.3254.78502.stgit@ellison.1015granger.net> <1329421931.4279.22.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 16, 2012, at 2:52 PM, Myklebust, Trond wrote:

> On Wed, 2012-02-15 at 16:34 -0500, Chuck Lever wrote:
>> Eliminate a number of implicit type casts in comparisons, and these
>> compiler warnings:
>> 
>> fs/nfs/dir.c: In function ‘nfs_readdir_clear_array’:
>> fs/nfs/dir.c:264:16: warning: comparison between signed and unsigned
>> 		integer expressions [-Wsign-compare]
>> fs/nfs/dir.c: In function ‘nfs_readdir_search_for_cookie’:
>> fs/nfs/dir.c:352:16: warning: comparison between signed and unsigned
>> 		integer expressions [-Wsign-compare]
>> fs/nfs/dir.c: In function ‘nfs_do_filldir’:
>> fs/nfs/dir.c:769:38: warning: comparison between signed and unsigned
>> 		integer expressions [-Wsign-compare]
>> fs/nfs/dir.c:780:9: warning: comparison between signed and unsigned
>> 		integer expressions [-Wsign-compare]
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> fs/nfs/dir.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>> 
>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>> index ac28990..8661e13 100644
>> --- a/fs/nfs/dir.c
>> +++ b/fs/nfs/dir.c
>> @@ -207,7 +207,7 @@ struct nfs_cache_array_entry {
>> };
>> 
>> struct nfs_cache_array {
>> -	unsigned int size;
>> +	int size;
>> 	int eof_index;
>> 	u64 last_cookie;
>> 	struct nfs_cache_array_entry array[0];
>> 
> 
> Nope. That's a cop-out: array sizes cannot be negative.

That's typically true, but IIRC the array size here can hold a "-1" as a special value.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




