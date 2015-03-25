Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mxip5-inbound.gatech.edu ([130.207.182.47]:57627 "EHLO
	mxip5-inbound.gatech.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbbCYUlP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 16:41:15 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2070.6\))
Subject: Re: [PATCH 1/1] nfsd: incorrect check for debugfs returns
From: Chengyu Song <csong84@gatech.edu>
In-Reply-To: <20150325200953.GA18143@fieldses.org>
Date: Wed, 25 Mar 2015 16:41:13 -0400
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Taesoo Kim <taesoo@gatech.edu>, changwoo@gatech.edu,
        sanidhya@gatech.edu, Byoungyoung Lee <blee@gatech.edu>
Message-Id: <3D357160-800C-4F45-B3D4-C6ECFD6CB8AF@gatech.edu>
References: <1427165885-20823-1-git-send-email-csong84@gatech.edu> <20150325151713.GC13764@fieldses.org> <761150A1-0BDC-47B0-B85D-857DC011E517@gatech.edu> <20150325200953.GA18143@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cool. Sent.

> On Mar 25, 2015, at 4:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Wed, Mar 25, 2015 at 12:41:29PM -0400, Chengyu Song wrote:
>> There may be a simpler solution, declare NFSD_FAULT_INJECTION has dependency
>> on DEBUG_FS, or automatically select DEBUG_FS.
> 
> Oh, I forgot about that--you're right, NFSD_FAULT_INJECTION isn't useful
> without DEBUG_FS anyway, so, sure, let's do that.
> 
> --b.
> 
>> I don't think current debugfs
>> implementation will return any error ptr once it's configured.
>> 
>> I choose to check the return instead, because I was worried the debugfs interface
>> may change in the future.
>> 
>> Does this sounds like a solution? If so, I can submit a patch for Kconfig.
>> 
>> Best,
>> Chengyu
>> 
>>> On Mar 25, 2015, at 11:17 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>> On Mon, Mar 23, 2015 at 10:58:05PM -0400, Chengyu Song wrote:
>>>> debugfs_create_dir and debugfs_create_file may return -ENODEV when debugfs
>>>> is not configured, so the return value should be checked against ERROR_VALUE
>>>> as well, otherwise the later dereference of the dentry pointer would crash
>>>> the kernel.
>>> 
>>> Thanks for spotting this.  But it looks like this will cause nfsd
>>> startup to fail when debugfs isn't configured.  I'd rather we didn't, it
>>> just isn't that important.
>>> 
>>> So I'd rather just make nfsd_fault_inject_init() a void return--just do
>>> a dprintk as a warning in the "fail" case, and otherwise let normal
>>> startup continue (and check that doesn't lead to other unsafe
>>> dereferences of debug_dir).  Could you try that?
>>> 
>>> --b.
>>> 
>>> 
>>>> 
>>>> Signed-off-by: Chengyu Song <csong84@gatech.edu>
>>>> ---
>>>> fs/nfsd/fault_inject.c | 12 ++++++++----
>>>> 1 file changed, 8 insertions(+), 4 deletions(-)
>>>> 
>>>> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
>>>> index c16bf5a..621d065 100644
>>>> --- a/fs/nfsd/fault_inject.c
>>>> +++ b/fs/nfsd/fault_inject.c
>>>> @@ -132,19 +132,23 @@ int nfsd_fault_inject_init(void)
>>>> 	unsigned int i;
>>>> 	struct nfsd_fault_inject_op *op;
>>>> 	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
>>>> +	struct dentry *dent;
>>>> 
>>>> -	debug_dir = debugfs_create_dir("nfsd", NULL);
>>>> -	if (!debug_dir)
>>>> +	dent = debugfs_create_dir("nfsd", NULL);
>>>> +	if (IS_ERR_OR_NULL(dent))
>>>> 		goto fail;
>>>> +	debug_dir = dent;
>>>> 
>>>> 	for (i = 0; i < NUM_INJECT_OPS; i++) {
>>>> 		op = &inject_ops[i];
>>>> -		if (!debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd))
>>>> +		dent = debugfs_create_file(op->file, mode, debug_dir, op, &fops_nfsd);
>>>> +		if (IS_ERR_OR_NULL(dent))
>>>> 			goto fail;
>>>> +
>>>> 	}
>>>> 	return 0;
>>>> 
>>>> fail:
>>>> 	nfsd_fault_inject_cleanup();
>>>> -	return -ENOMEM;
>>>> +	return dent ? PTR_ERR(dent) : -ENOMEM;
>>>> }
>>>> -- 
>>>> 2.1.0

