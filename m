Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35060 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754930AbcLNJPM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Dec 2016 04:15:12 -0500
Subject: Re: [RESEND PATCH v4 1/2] sysctl: introduce new proc handler
 proc_dobool
To: kbuild test robot <lkp@intel.com>
References: <201612141454.bVs7TA70%fengguang.wu@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>,
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
From: hejianet <hejianet@gmail.com>
Message-ID: <f269cce5-52cf-b0d8-a419-64c0f002df2e@gmail.com>
Date: Wed, 14 Dec 2016 17:14:48 +0800
MIME-Version: 1.0
In-Reply-To: <201612141454.bVs7TA70%fengguang.wu@intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, this error is caused by

# CONFIG_PROC_SYSCTL is not set

Will fixed in next version

Jia

B.R.


On 12/14/16 2:13 PM, kbuild test robot wrote:
> Hi Jia,
>
> [auto build test ERROR on linus/master]
> [also build test ERROR on v4.9 next-20161214]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Jia-He/sysctl-introduce-new-proc-handler-proc_dobool/20161214-112656
> config: x86_64-randconfig-n0-12141159 (attached as .config)
> compiler: gcc-4.8 (Debian 4.8.4-1) 4.8.4
> reproduce:
>          # save the attached .config to linux build tree
>          make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>>> kernel/built-in.o:(___ksymtab+proc_dobool+0x0): undefined reference to `proc_dobool'
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

