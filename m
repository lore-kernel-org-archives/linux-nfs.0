Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:37150 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755418AbcLOIOk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Dec 2016 03:14:40 -0500
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBF83moS112560
        for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2016 03:13:52 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27bpe4bgqc-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Thu, 15 Dec 2016 03:13:51 -0500
Received: from localhost
        by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <xinhui@linux.vnet.ibm.com>;
        Thu, 15 Dec 2016 18:13:49 +1000
Subject: Re: [PATCH v5 1/2] sysctl: introduce new proc handler proc_dobool
To: Jia He <hejianet@gmail.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
References: <1481786661-973-1-git-send-email-hejianet@gmail.com>
 <1481786661-973-2-git-send-email-hejianet@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Serge Hallyn <serge@hallyn.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mel Gorman <mgorman@techsingularity.net>,
        Kees Cook <keescook@chromium.org>, Hugh Dickins <hughd@google.com>,
        Daniel Bristot de Oliveira <bristot@redhat.com>,
        Daniel Cashman <dcashman@google.com>, Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
From: Pan Xinhui <xinhui@linux.vnet.ibm.com>
Date: Thu, 15 Dec 2016 16:13:29 +0800
MIME-Version: 1.0
In-Reply-To: <1481786661-973-2-git-send-email-hejianet@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Message-Id: <a656f658-c89a-284e-31ca-e4a8f64bf1fe@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



在 2016/12/15 15:24, Jia He 写道:
> This is to let bool variable could be correctly displayed in
> big/little endian sysctl procfs. sizeof(bool) is arch dependent,
> proc_dobool should work in all arches.
>
> Suggested-by: Pan Xinhui <xinhui@linux.vnet.ibm.com>
> Signed-off-by: Jia He <hejianet@gmail.com>
> ---
>  include/linux/sysctl.h |  2 ++
>  kernel/sysctl.c        | 41 +++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 43 insertions(+)
>

Reviewed-by: Pan Xinhui <xinhui.pan@linux.vnet.ibm.com>

> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index adf4e51..255a9c7 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -41,6 +41,8 @@ typedef int proc_handler (struct ctl_table *ctl, int write,
>
>  extern int proc_dostring(struct ctl_table *, int,
>  			 void __user *, size_t *, loff_t *);
> +extern int proc_dobool(struct ctl_table *, int,
> +			void __user *, size_t *, loff_t *);
>  extern int proc_dointvec(struct ctl_table *, int,
>  			 void __user *, size_t *, loff_t *);
>  extern int proc_douintvec(struct ctl_table *, int,
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 706309f..c4bec65 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -2112,6 +2112,20 @@ static int proc_put_char(void __user **buf, size_t *size, char c)
>  	return 0;
>  }
>
> +static int do_proc_dobool_conv(bool *negp, unsigned long *lvalp,
> +				int *valp,
> +				int write, void *data)
> +{
> +	if (write)
> +		*(bool *)valp = *lvalp;
> +	else {
> +		int val = *(bool *)valp;
> +
> +		*lvalp = (unsigned long)val;
> +	}
> +	return 0;
> +}
> +
>  static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
>  				 int *valp,
>  				 int write, void *data)
> @@ -2258,6 +2272,26 @@ static int do_proc_dointvec(struct ctl_table *table, int write,
>  }
>
>  /**
> + * proc_dobool - read/write a bool
> + * @table: the sysctl table
> + * @write: %TRUE if this is a write to the sysctl file
> + * @buffer: the user buffer
> + * @lenp: the size of the user buffer
> + * @ppos: file position
> + *
> + * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
> + * values from/to the user buffer, treated as an ASCII string.
> + *
> + * Returns 0 on success.
> + */
> +int proc_dobool(struct ctl_table *table, int write,
> +		void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +	return do_proc_dointvec(table, write, buffer, lenp, ppos,
> +				do_proc_dobool_conv, NULL);
> +}
> +
> +/**
>   * proc_dointvec - read a vector of integers
>   * @table: the sysctl table
>   * @write: %TRUE if this is a write to the sysctl file
> @@ -2885,6 +2919,12 @@ int proc_dostring(struct ctl_table *table, int write,
>  	return -ENOSYS;
>  }
>
> +int proc_dobool(struct ctl_table *table, int write,
> +                  void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +        return -ENOSYS;
> +}
> +
>  int proc_dointvec(struct ctl_table *table, int write,
>  		  void __user *buffer, size_t *lenp, loff_t *ppos)
>  {
> @@ -2941,6 +2981,7 @@ int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
>   * No sense putting this after each symbol definition, twice,
>   * exception granted :-)
>   */
> +EXPORT_SYMBOL(proc_dobool);
>  EXPORT_SYMBOL(proc_dointvec);
>  EXPORT_SYMBOL(proc_douintvec);
>  EXPORT_SYMBOL(proc_dointvec_jiffies);
>

