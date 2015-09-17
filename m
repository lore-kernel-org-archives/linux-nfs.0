Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:11768 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbbIQNor (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Sep 2015 09:44:47 -0400
Subject: Re: [PATCH] nfs: fix v4.2 SEEK on files over 2 gigs
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <20150916212127.GA5169@fieldses.org> <55FABA40.6010406@Netapp.com>
 <20150917132552.GD9870@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55FAC3CA.3050205@Netapp.com>
Date: Thu, 17 Sep 2015 09:44:42 -0400
MIME-Version: 1.0
In-Reply-To: <20150917132552.GD9870@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/17/2015 09:25 AM, J. Bruce Fields wrote:
> On Thu, Sep 17, 2015 at 09:04:00AM -0400, Anna Schumaker wrote:
>> Hey Bruce,
>>
>> I actually worked on a version of this patch on my own yesterday, too.  Looks like you beat me to submitting it!  :)
> 
> Oh, OK, well feel free to credit it however you'd like.
> 
>> On 09/16/2015 05:21 PM, J. Bruce Fields wrote:
>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>>
>>> We're incorrectly assigning a loff_t return to an int.  If SEEK_HOLE or
>>> SEEK_DATA returns an offset over 2^31 then the application will see a
>>> weird lseek() result (usually -EIO).
>>
>> I saw roughly the same thing with xfstests generic/285.
> 
> I maybe should have included my reproducer in the changelog, which was:
> 
> 	git clone git://git.infradead.org/users/dedekind/bmap-tools.git
> 	cd bmap-tools
> 
> 	mount overs=4.2 localhost:/exports /mnt/
> 	dd if=/dev/zero of=/mnt/test1.image seek=2097152 bs=1K count=1
> 
> 	./bmaptool  create  /mnt/test1.image
> 
> In the good case it outputs some xml, in the bad case it aborts with an
> IO error.

That's roughly what I see, too:

$ cat results/generic/285.out.bad
...
10. Test a huge file for offset overflow              
10.01 SEEK_HOLE expected 2097152 or 8589934592, got 2097152.      succ
10.02 SEEK_HOLE expected 2097152 or 8589934592, got 2097152.      succ
10.03 SEEK_DATA expected 0 or 0, got 0.                           succ
10.04 SEEK_DATA expected 1 or 1, got 1.                           succ
10.05 SEEK_HOLE expected 8589934592 or 8589934592, got 0.         FAIL
10.06 SEEK_DATA expected 8587837440 or 8587837440, got -1.        FAIL
10.07 SEEK_DATA expected 8587837441 or 8587837441, got -1.        FAIL
10.08 SEEK_DATA expected 8587837440 or 8587837440, got -1.        FAIL

> 
> --b.
> 
>>> Cc: stable@vger.kernel.org
>>> Fixes: bdcc2cd14e4e "NFSv4.2: handle NFS-specific llseek errors"
>>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>
>> Reviewed-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
>>
>>> ---
>>>  fs/nfs/nfs42proc.c | 4 +++-
>>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
>>> index d731bbf974aa..0f020e4d8421 100644
>>> --- a/fs/nfs/nfs42proc.c
>>> +++ b/fs/nfs/nfs42proc.c
>>> @@ -175,10 +175,12 @@ loff_t nfs42_proc_llseek(struct file *filep, loff_t offset, int whence)
>>>  {
>>>  	struct nfs_server *server = NFS_SERVER(file_inode(filep));
>>>  	struct nfs4_exception exception = { };
>>> -	int err;
>>> +	loff_t err;
>>>  
>>>  	do {
>>>  		err = _nfs42_proc_llseek(filep, offset, whence);
>>> +		if (err >= 0)
>>> +			break;
>>>  		if (err == -ENOTSUPP)
>>>  			return -EOPNOTSUPP;
>>>  		err = nfs4_handle_exception(server, err, &exception);
>>>

