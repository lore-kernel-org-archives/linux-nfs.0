From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 24/46] NFS: fix decode_fs_locations_maxsz
Date: Mon, 30 Mar 2009 14:32:16 +0300
Message-ID: <49D0ADC0.2020302@panasas.com>
References: <49ADBD04.2090002@panasas.com>	 <1236124672-3656-1-git-send-email-bhalevy@panasas.com> <1238348417.23986.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:19136 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754238AbZC3LdO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 07:33:14 -0400
In-Reply-To: <1238348417.23986.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 29, 2009, 20:40 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Tue, 2009-03-03 at 16:57 -0700, Benny Halevy wrote:
>> need to take into account the getattr reply.
>>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4xdr.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index b60dc56..0e01660 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -239,7 +239,7 @@ static int nfs4_stat_to_errno(int);
>>  #define encode_fs_locations_maxsz \
>>                                 (encode_getattr_maxsz)
>>  #define decode_fs_locations_maxsz \
>> -                               (0)
>> +                               (decode_getattr_maxsz)
> 
> This is a bit excessive. If you look at xdr_enc_fs_locations, you'll see
> that this just needs to decode the OP_GETATTR + status. All the data
> goes into the page.

You're right.  I'll revert this patch.

Benny

> 
>>  #define NFS4_enc_compound_sz   (1024)  /* XXX: large enough? */
>>  #define NFS4_dec_compound_sz   (1024)  /* XXX: large enough? */
>>  #define NFS4_enc_read_sz       (compound_encode_hdr_maxsz + \
>> --
>> 1.6.1.3
>>
>>
>>
