Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:36810 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752978AbcLKRnn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2016 12:43:43 -0500
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBBHd9cJ105940
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2016 12:43:42 -0500
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
        by mx0a-001b2d01.pphosted.com with ESMTP id 278f3ddmh9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2016 12:43:42 -0500
Received: from localhost
        by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <linux-nfs@vger.kernel.org> from <xinhui@linux.vnet.ibm.com>;
        Sun, 11 Dec 2016 23:13:38 +0530
Subject: Re: [PATCH v2 1/1] lockd: Change nsm_use_hostnames from bool to u32
To: Jia He <hejianet@gmail.com>, linux-nfs@vger.kernel.org
References: <1481470609-31488-1-git-send-email-hejianet@gmail.com>
 <1481470609-31488-2-git-send-email-hejianet@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-kernel@vger.kernel.org
From: Pan Xinhui <xinhui@linux.vnet.ibm.com>
Date: Mon, 12 Dec 2016 01:43:35 +0800
MIME-Version: 1.0
In-Reply-To: <1481470609-31488-2-git-send-email-hejianet@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Message-Id: <819a5924-6fd4-adce-c03f-2a83c99d0a27@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


hi, jia
	nice catch!
However I think we should fix it totally.
This is because do_proc_dointvec_conv() try to get a int value from a bool *.

something like below might help. pls. ignore the code style and this is tested :)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index fc4084e..7eeaee4 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -519,6 +519,8 @@ EXPORT_SYMBOL_GPL(lockd_down);
   * Sysctl parameters (same as module parameters, different interface).
   */
  
+int proc_dou8vec(struct ctl_table *table, int write,
+                                    void __user *buffer, size_t *lenp, loff_t *ppos);
  static struct ctl_table nlm_sysctls[] = {
         {
                 .procname       = "nlm_grace_period",
@@ -561,7 +563,7 @@ static struct ctl_table nlm_sysctls[] = {
                 .data           = &nsm_use_hostnames,
                 .maxlen         = sizeof(int),
                 .mode           = 0644,
-               .proc_handler   = proc_dointvec,
+               .proc_handler   = proc_dou8vec,
         },
         {
                 .procname       = "nsm_local_state",
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 706309f..6307737 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2112,6 +2112,30 @@ static int proc_put_char(void __user **buf, size_t *size, char c)
         return 0;
  }
  
+
+static int do_proc_dou8vec_conv(bool *negp, unsigned long *lvalp,
+                                u8 *valp,
+                                int write, void *data)
+{
+       if (write) {
+               if (*negp) {
+                       *valp = -*lvalp;
+               } else {
+                       *valp = *lvalp;
+               }
+       } else {
+               int val = *valp;
+               if (val < 0) {
+                       *negp = true;
+                       *lvalp = -(unsigned long)val;
+               } else {
+                       *negp = false;
+                       *lvalp = (unsigned long)val;
+               }
+       }
+       return 0;
+}
+
  static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
                                  int *valp,
                                  int write, void *data)
@@ -2296,6 +2320,14 @@ int proc_douintvec(struct ctl_table *table, int write,
                                 do_proc_douintvec_conv, NULL);
  }
  
+int proc_dou8vec(struct ctl_table *table, int write,
+                    void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+       return do_proc_dointvec(table, write, buffer, lenp, ppos,
+                               do_proc_dou8vec_conv, NULL);
+}
+
+

在 2016/12/11 23:36, Jia He 写道:
> nsm_use_hostnames is a module paramter and it will be exported to sysctl
> procfs. This is to let user sometimes change it from userspace. But the
> minimal unit for sysctl procfs read/write it sizeof(int).
> In big endian system, the converting from/to  bool to/from int will cause
> error for proc items.
>
> This patch changes the type definition of nsm_use_hostnames.
>
> V2: Changes extern type in lockd.h
> Signed-off-by: Jia He <hejianet@gmail.com>
> ---
>  fs/lockd/mon.c              | 2 +-
>  fs/lockd/svc.c              | 2 +-
>  include/linux/lockd/lockd.h | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
> index 19166d4..3e7ff4d 100644
> --- a/fs/lockd/mon.c
> +++ b/fs/lockd/mon.c
> @@ -57,7 +57,7 @@ static				DEFINE_SPINLOCK(nsm_lock);
>   * Local NSM state
>   */
>  u32	__read_mostly		nsm_local_state;
> -bool	__read_mostly		nsm_use_hostnames;
> +u32	__read_mostly		nsm_use_hostnames;
>
>  static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
>  {
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index fc4084e..308033d 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -658,7 +658,7 @@ module_param_call(nlm_udpport, param_set_port, param_get_int,
>  		  &nlm_udpport, 0644);
>  module_param_call(nlm_tcpport, param_set_port, param_get_int,
>  		  &nlm_tcpport, 0644);
> -module_param(nsm_use_hostnames, bool, 0644);
> +module_param(nsm_use_hostnames, u32, 0644);
>  module_param(nlm_max_connections, uint, 0644);
>
>  static int lockd_init_net(struct net *net)
> diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
> index c153738..db52152 100644
> --- a/include/linux/lockd/lockd.h
> +++ b/include/linux/lockd/lockd.h
> @@ -196,7 +196,7 @@ extern struct svc_procedure	nlmsvc_procedures4[];
>  #endif
>  extern int			nlmsvc_grace_period;
>  extern unsigned long		nlmsvc_timeout;
> -extern bool			nsm_use_hostnames;
> +extern u32			nsm_use_hostnames;
>  extern u32			nsm_local_state;
>
>  /*
>

