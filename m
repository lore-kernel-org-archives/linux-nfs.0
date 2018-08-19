Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33353 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725940AbeHSPdG (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Aug 2018 11:33:06 -0400
MIME-Version: 1.0
References: <20180818132434.9515-1-linux@rasmusvillemoes.dk>
In-Reply-To: <20180818132434.9515-1-linux@rasmusvillemoes.dk>
From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Sun, 19 Aug 2018 15:21:36 +0300
Message-ID: <CAHp75Ve21BhYsXQHsr285VArqALi0Rt4BXudfmTXU+E+xr+5NQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/8] seq_file: introduce seq_open_data helper
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Jonathan Corbet <corbet@lwn.net>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        adilger@dilger.ca,
        Linux Documentation List <linux-doc@vger.kernel.org>,
        Linux FS Devel <linux-fsdevel@vger.kernel.org>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        linux-nfs@vger.kernel.org, cluster-devel@redhat.com,
        Michael Ellerman <mpe@ellerman.id.au>,
        "open list:LINUX FOR POWERPC PA SEMI PWRFICIENT"
        <linuxppc-dev@lists.ozlabs.org>,
        Thierry Reding <thierry.reding@gmail.com>,
        Lorenzo Pieralisi <lorenzo.pieralisi@arm.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 18, 2018 at 4:26 PM Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
>
> There are quite a few callers of seq_open that could be simplified by
> setting the ->private member via the seq_open call instead of fetching
> file->private_data afterwards.
>

I like this series,
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>

P.S. ...though it seems patch 3 missed a commit message.

> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
> v2:
> - Fix some copy-pastos spotted by Andreas.
> - Ensure everybody hit by an example patch also gets this cover letter/introducing patch.
> - Include a few fs/ examples.
>
> I've just included a few examples of possible users of this helper,
> there are many more similar cases. As a bonus, 7/8 fix a potential
> NULL deref (if one believes that seq_open can actually fail).
>
> seq_open_private would have been a better name, but that one is
> already taken...
>
> Documentation/filesystems/seq_file.txt |  9 +++++----
>  fs/seq_file.c                          | 16 ++++++++++++----
>  include/linux/seq_file.h               |  1 +
>  3 files changed, 18 insertions(+), 8 deletions(-)
>
> diff --git a/Documentation/filesystems/seq_file.txt b/Documentation/filesystems/seq_file.txt
> index 9de4303201e1..68571b8275d8 100644
> --- a/Documentation/filesystems/seq_file.txt
> +++ b/Documentation/filesystems/seq_file.txt
> @@ -234,10 +234,11 @@ Here, the call to seq_open() takes the seq_operations structure we created
>  before, and gets set up to iterate through the virtual file.
>
>  On a successful open, seq_open() stores the struct seq_file pointer in
> -file->private_data. If you have an application where the same iterator can
> -be used for more than one file, you can store an arbitrary pointer in the
> -private field of the seq_file structure; that value can then be retrieved
> -by the iterator functions.
> +file->private_data. If you have an application where the same iterator
> +can be used for more than one file, you can store an arbitrary pointer
> +in the private field of the seq_file structure; that value can then be
> +retrieved by the iterator functions. Using the wrapper seq_open_data()
> +allows you to set the initial value for that field.
>
>  There is also a wrapper function to seq_open() called seq_open_private(). It
>  kmallocs a zero filled block of memory and stores a pointer to it in the
> diff --git a/fs/seq_file.c b/fs/seq_file.c
> index 4cc090b50cc5..c8c86660f6db 100644
> --- a/fs/seq_file.c
> +++ b/fs/seq_file.c
> @@ -33,11 +33,12 @@ static void *seq_buf_alloc(unsigned long size)
>  }
>
>  /**
> - *     seq_open -      initialize sequential file
> + *     seq_open_data - initialize sequential file
>   *     @file: file we initialize
>   *     @op: method table describing the sequence
> + *     @data: initial value for ->private field
>   *
> - *     seq_open() sets @file, associating it with a sequence described
> + *     seq_open_data() sets @file, associating it with a sequence described
>   *     by @op.  @op->start() sets the iterator up and returns the first
>   *     element of sequence. @op->stop() shuts it down.  @op->next()
>   *     returns the next element of sequence.  @op->show() prints element
> @@ -45,10 +46,10 @@ static void *seq_buf_alloc(unsigned long size)
>   *     ERR_PTR(error).  In the end of sequence they return %NULL. ->show()
>   *     returns 0 in case of success and negative number in case of error.
>   *     Returning SEQ_SKIP means "discard this element and move on".
> - *     Note: seq_open() will allocate a struct seq_file and store its
> + *     Note: seq_open_data() will allocate a struct seq_file and store its
>   *     pointer in @file->private_data. This pointer should not be modified.
>   */
> -int seq_open(struct file *file, const struct seq_operations *op)
> +int seq_open_data(struct file *file, const struct seq_operations *op, void *data)
>  {
>         struct seq_file *p;
>
> @@ -62,6 +63,7 @@ int seq_open(struct file *file, const struct seq_operations *op)
>
>         mutex_init(&p->lock);
>         p->op = op;
> +       p->private = data;
>
>         // No refcounting: the lifetime of 'p' is constrained
>         // to the lifetime of the file.
> @@ -86,6 +88,12 @@ int seq_open(struct file *file, const struct seq_operations *op)
>         file->f_mode &= ~FMODE_PWRITE;
>         return 0;
>  }
> +EXPORT_SYMBOL(seq_open_data);
> +
> +int seq_open(struct file *file, const struct seq_operations *op)
> +{
> +       return seq_open_data(file, op, NULL);
> +}
>  EXPORT_SYMBOL(seq_open);
>
>  static int traverse(struct seq_file *m, loff_t offset)
> diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
> index a121982af0f5..1142e39bfad2 100644
> --- a/include/linux/seq_file.h
> +++ b/include/linux/seq_file.h
> @@ -107,6 +107,7 @@ void seq_pad(struct seq_file *m, char c);
>
>  char *mangle_path(char *s, const char *p, const char *esc);
>  int seq_open(struct file *, const struct seq_operations *);
> +int seq_open_data(struct file *, const struct seq_operations *, void *);
>  ssize_t seq_read(struct file *, char __user *, size_t, loff_t *);
>  loff_t seq_lseek(struct file *, loff_t, int);
>  int seq_release(struct inode *, struct file *);
> --
> 2.16.4
>


-- 
With Best Regards,
Andy Shevchenko
