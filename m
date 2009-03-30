From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 17/46] nfs41: use nfs4_getaclres
Date: Mon, 30 Mar 2009 11:47:29 +0300
Message-ID: <49D08721.7040207@panasas.com>
References: <49ADBD04.2090002@panasas.com>	 <1236124495-3430-1-git-send-email-bhalevy@panasas.com> <1238347692.10999.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2278 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752323AbZC3Irf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Mar 2009 04:47:35 -0400
In-Reply-To: <1238347692.10999.16.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 29, 2009, 20:28 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Tue, 2009-03-03 at 16:54 -0700, Benny Halevy wrote:
>> In preparation for nfs41 sequence processing.
>>
>> Signed-off-by: Andy Admason <andros@netapp.com>
>> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>> ---
>>  fs/nfs/nfs4proc.c |    7 +++++--
>>  fs/nfs/nfs4xdr.c  |    5 +++--
>>  2 files changed, 8 insertions(+), 4 deletions(-)
>>
>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>> index 4db965c..1a5fa1d 100644
>> --- a/fs/nfs/nfs4proc.c
>> +++ b/fs/nfs/nfs4proc.c
>> @@ -2822,17 +2822,20 @@ out:
>>  static ssize_t __nfs4_get_acl_uncached(struct inode *inode, void
>> *buf, size_t buflen)
>>  {
>>         struct page *pages[NFS4ACL_MAXPAGES];
>> +       size_t resp_len = buflen;
>>         struct nfs_getaclargs args = {
>>                 .fh = NFS_FH(inode),
>>                 .acl_pages = pages,
>>                 .acl_len = buflen,
>>         };
>> -       size_t resp_len = buflen;
>> +       struct nfs_getaclres res = {
>> +               .acl_len = &resp_len,
>> +       };
> 
> Please embed resp_len in nfs_getaclres. There is no need for a double
> indirection here...
> 

Right.  Thanks!

Benny
