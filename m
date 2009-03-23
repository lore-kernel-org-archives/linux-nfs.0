From: Masahiro Tamori <masahiro.tamori@gmail.com>
Subject: Re: [Patch] ltt-relay-alloc mmap support (due to NFS lack of splice
	support)
Date: Mon, 23 Mar 2009 21:34:21 +0900
Message-ID: <91e0b5050903230534g57d1ef8byd14a1fb5ca807192@mail.gmail.com>
References: <91e0b5050903170224k51c4895eq8a1491da7a7a9741@mail.gmail.com>
	 <20090320152857.GB30019@Krystal>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ltt-dev <ltt-dev-33AaDErTWvBVxDZ2/Zk0YoryAYyacSEB@public.gmane.org>,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	linux-nfs@vger.kernel.org, linux-embedded@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:64834 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332AbZCWMeZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Mar 2009 08:34:25 -0400
In-Reply-To: <20090320152857.GB30019@Krystal>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2009/3/21 Mathieu Desnoyers <mathieu.desnoyers-scC8bbJcJLCw5LPnMra/2Q@public.gmane.org>:
> * Masahiro Tamori (masahiro.tamori@gmail.com) wrote:
>> Hello Mathieu,
>>
>> I use the following version.
>> LTTV 0.12.12
>> LTTng 0.110
>> LTT Control 0.67
>> Kernles 2.6.29-rc7
>>
>> The target is ARM RealviewEB.
>>
>> Our customer will use NFS to store trace data not storage device for
>> embedded devices.
>> Since newer lttng use splice() even if NFS can not support splice(),
>> I create a patch to support to mmap of ltt-relay-alloc.
>>
>> I will send a mail to this mailing list for ltt-control patch.
>> I do not know which mailing list should be posted for userland tools=
=2E
>>
>> Best Regards,
>> Masahiro Tamori
>>
>>
>> ltt-relay-alloc mmap support
>>
>> Splice syscall does not support NFS. We can not save trace data to
>> NFS directory. If this feature is enabled, you can use mmap()
>> instead of splice().
>>
>
>
> Hi Masahiro,
>
> Maybe we should consider implementing splice() support in NFS instead=
 ?
>
> I removed the mmap support from the ltt-relay-alloc files because spl=
ice
> is more efficient and does not require to vmap the pages. =A0Unless t=
here
> is a strong argument telling what in NFS makes it impossible to
> implement splice(), I don't really see the gain in putting back the
> old mmap() mechanism we had.
>
> Maybe the NFS people will have some information about this ?
>
> Thanks,
>
> Mathieu
>

Hello Mathieu,

I think that the best solution is NFS can support splice() even if
it cannot zero copy.

The splice() will be used by any other tools, hence NFS should support
it sooner or later.

If technical issue is remained to support splice() in NFS,
we should support mmap in LTTng until the problem is resolved.
Embedded people will want to use LTTng with NFS,
though this is a bad choice.

Thank you,
Masahiro Tamori

>
>> For embeded system, NFS must be used. Target board has not enough me=
mory
>> to save trace data and some board can not connect ATA, USB and some =
strage
>> devices.
>>
>> Signed-off-by: Masahiro.Tamori@gmail.com
>> ---
>>  ltt/Kconfig              |   11      11 +    0 -     0 !
>>  ltt/ltt-relay-alloc.c    |   88      88 +    0 -     0 !
>>  ltt/ltt-relay-lockless.c |   15      15 +    0 -     0 !
>>  3 files changed, 114 insertions(+)
>>
>> Index: b/ltt/Kconfig
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- a/ltt/Kconfig
>> +++ b/ltt/Kconfig
>> @@ -66,6 +66,17 @@ choice
>>
>>  endchoice
>>
>> +config LTT_RELAY_ALLOC_MMAP
>> +     bool "Linux Trace Toolkit Relay mmap Support"
>> +     depends on LTT_RELAY_ALLOC
>> +     default y
>> +     help
>> +       Support mmap for ltt-relay.
>> +
>> +       Splice syscall does not support NFS. We can not save trace d=
ata to
>> +          NFS directory. If this feature is enabled, you can use mm=
ap()
>> +          instead of splice().
>> +
>>  config LTT_SERIALIZE
>>       tristate "Linux Trace Toolkit Serializer"
>>       depends on LTT_RELAY_ALLOC
>> Index: b/ltt/ltt-relay-alloc.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- a/ltt/ltt-relay-alloc.c
>> +++ b/ltt/ltt-relay-alloc.c
>> @@ -27,6 +27,74 @@
>>  static DEFINE_MUTEX(relay_channels_mutex);
>>  static LIST_HEAD(relay_channels);
>>
>> +#ifdef CONFIG_LTT_RELAY_ALLOC_MMAP
>> +/*
>> + * close() vm_op implementation for relay file mapping.
>> + */
>> +static void relay_file_mmap_close(struct vm_area_struct *vma)
>> +{
>> +}
>> +
>> +/*
>> + * fault() vm_op implementation for relay file mapping.
>> + */
>> +static int relay_buf_fault(struct vm_area_struct *vma, struct vm_fa=
ult *vmf)
>> +{
>> +     struct page *page =3D NULL;
>> +     struct rchan_buf *buf =3D vma->vm_private_data;
>> +     pgoff_t pgoff =3D vmf->pgoff;
>> +     struct page **pages;
>> +
>> +     if (!buf)
>> +             return VM_FAULT_OOM;
>> +
>> +     if (pgoff >=3D buf->page_count)
>> +             return VM_FAULT_SIGBUS;
>> +
>> +     pages =3D buf->pages;
>> +     page =3D pages[pgoff];
>> +     get_page(page);
>> +     vmf->page =3D page;
>> +
>> +     return 0;
>> +}
>> +
>> +/*
>> + * vm_ops for relay file mappings.
>> + */
>> +static struct vm_operations_struct relay_file_mmap_ops =3D {
>> +     .fault =3D relay_buf_fault,
>> +     .close =3D relay_file_mmap_close,
>> +};
>> +
>> +/**
>> + *   relay_mmap_buf: - mmap channel buffer to process address space
>> + *   @buf: relay channel buffer
>> + *   @vma: vm_area_struct describing memory to be mapped
>> + *
>> + *   Returns 0 if ok, negative on error
>> + *
>> + *   Caller should already have grabbed mmap_sem.
>> + */
>> +static int relay_mmap_buf(struct rchan_buf *buf, struct vm_area_str=
uct *vma)
>> +{
>> +     unsigned long length =3D vma->vm_end - vma->vm_start;
>> +
>> +     if (!buf)
>> +             return -EBADF;
>> +
>> +     if (length !=3D (unsigned long)buf->chan->alloc_size)
>> +             return -EINVAL;
>> +
>> +     vma->vm_ops =3D &relay_file_mmap_ops;
>> +     vma->vm_flags |=3D VM_DONTEXPAND;
>> +     vma->vm_private_data =3D buf;
>> +
>> +     return 0;
>> +}
>> +
>> +#endif /* CONFIG_LTT_RELAY_ALLOC_MMAP */
>> +
>>  /**
>>   *   relay_alloc_buf - allocate a channel buffer
>>   *   @buf: the buffer struct
>> @@ -601,6 +669,23 @@ static int relay_file_open(struct inode
>>       return nonseekable_open(inode, filp);
>>  }
>>
>> +#ifdef CONFIG_LTT_RELAY_ALLOC_MMAP
>> +
>> +/**
>> + *   relay_file_mmap - mmap file op for relay files
>> + *   @filp: the file
>> + *   @vma: the vma describing what to map
>> + *
>> + *   Calls upon relay_mmap_buf() to map the file into user space.
>> + */
>> +static int relay_file_mmap(struct file *filp, struct vm_area_struct=
 *vma)
>> +{
>> +     struct rchan_buf *buf =3D filp->private_data;
>> +     return relay_mmap_buf(buf, vma);
>> +}
>> +
>> +#endif /* CONFIG_LTT_RELAY_ALLOC_MMAP */
>> +
>>  /**
>>   *   relay_file_release - release file op for relay files
>>   *   @inode: the inode
>> @@ -619,6 +704,9 @@ static int relay_file_release(struct ino
>>
>>  const struct file_operations ltt_relay_file_operations =3D {
>>       .open           =3D relay_file_open,
>> +#ifdef CONFIG_LTT_RELAY_ALLOC_MMAP
>> +     .mmap           =3D relay_file_mmap,
>> +#endif
>>       .release        =3D relay_file_release,
>>  };
>>  EXPORT_SYMBOL_GPL(ltt_relay_file_operations);
>> Index: b/ltt/ltt-relay-lockless.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- a/ltt/ltt-relay-lockless.c
>> +++ b/ltt/ltt-relay-lockless.c
>> @@ -427,6 +427,18 @@ static int ltt_release(struct inode *ino
>>  }
>>
>>  /**
>> + *   ltt_mmap - mmap file op for ltt files
>> + *   @inode: opened inode
>> + *   @file: opened file
>> + *
>> + *   Mmap implementation.
>> + */
>> +static int ltt_mmap(struct file *file,  struct vm_area_struct *vma)
>> +{
>> +     return ltt_relay_file_operations.mmap(file, vma);
>> +}
>> +
>> +/**
>>   *   ltt_poll - file op for ltt files
>>   *   @filp: the file
>>   *   @wait: poll table
>> @@ -1590,6 +1602,9 @@ static struct ltt_transport ltt_relay_tr
>>  static const struct file_operations ltt_file_operations =3D {
>>       .open =3D ltt_open,
>>       .release =3D ltt_release,
>> +#ifdef CONFIG_LTT_RELAY_ALLOC_MMAP
>> +     .mmap           =3D ltt_mmap,
>> +#endif
>>       .poll =3D ltt_poll,
>>       .splice_read =3D ltt_relay_file_splice_read,
>>       .ioctl =3D ltt_ioctl,
>
> --
> Mathieu Desnoyers
> OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BA=
E 9A68
>
