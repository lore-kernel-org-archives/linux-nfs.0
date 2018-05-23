Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:56174 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932501AbeEWLyK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2018 07:54:10 -0400
Received: by mail-wm0-f67.google.com with SMTP id a8-v6so8162721wmg.5
        for <linux-nfs@vger.kernel.org>; Wed, 23 May 2018 04:54:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAFqt6zaM7kBSm1kkEp1KKYS=o0Jp0Y-kEP5AXNqsrrppZrPqeQ@mail.gmail.com>
References: <20180414194442.GA20044@jordon-HP-15-Notebook-PC> <CAFqt6zaM7kBSm1kkEp1KKYS=o0Jp0Y-kEP5AXNqsrrppZrPqeQ@mail.gmail.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 23 May 2018 17:24:08 +0530
Message-ID: <CAFqt6zZPWBfmYMiArKmv1f8f_VhRg=q5XLUUkJcR1EAo=UOqtQ@mail.gmail.com>
Subject: Re: [PATCH] fs: nfs: Adding new return type vm_fault_t
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org, Matthew Wilcox <willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 12, 2018 at 12:00 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
> On Sun, Apr 15, 2018 at 1:14 AM, Souptick Joarder <jrdr.linux@gmail.com> wrote:
>> Use new return type vm_fault_t for page_mkwrite
>> handler.
>>
>> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
>> Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
>> ---
>>  fs/nfs/file.c | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
>> index 81cca49..29553fd 100644
>> --- a/fs/nfs/file.c
>> +++ b/fs/nfs/file.c
>> @@ -532,13 +532,13 @@ static void nfs_swap_deactivate(struct file *file)
>>   * writable, implying that someone is about to modify the page through a
>>   * shared-writable mapping
>>   */
>> -static int nfs_vm_page_mkwrite(struct vm_fault *vmf)
>> +static vm_fault_t nfs_vm_page_mkwrite(struct vm_fault *vmf)
>>  {
>>         struct page *page = vmf->page;
>>         struct file *filp = vmf->vma->vm_file;
>>         struct inode *inode = file_inode(filp);
>>         unsigned pagelen;
>> -       int ret = VM_FAULT_NOPAGE;
>> +       vm_fault_t ret = VM_FAULT_NOPAGE;
>>         struct address_space *mapping;
>>
>>         dfprintk(PAGECACHE, "NFS: vm_page_mkwrite(%pD2(%lu), offset %lld)\n",
>> --
>> 1.9.1
>>
>
> Any comment for this patch ? We would like to get this patch
> queued for 4.18.

If no comment, We would like to get this patch in queue for 4.18.
