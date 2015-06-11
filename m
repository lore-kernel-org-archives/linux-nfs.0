Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:16949 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbbFKQoZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2015 12:44:25 -0400
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [nfs:testing 20/22] net/sunrpc/debugfs.c:307:8: note: in expansion of macro 'min'
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <201506111234.AT1CSPTP%fengguang.wu@intel.com>
Date: Thu, 11 Jun 2015 12:44:39 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <8E013A54-0FAA-472F-8EC0-85B9E97A90A3@oracle.com>
References: <201506111234.AT1CSPTP%fengguang.wu@intel.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 11, 2015, at 12:24 AM, kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
> head:   5a2dd67f38fa155bdd17ff6c3222a77adabdd508
> commit: 4a06825839889cc1756d0dd8a52d6b1071ee0263 [20/22] SUNRPC: Transport fault injection
> config: mn10300-allmodconfig (attached as .config)
> reproduce:
>  wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>  chmod +x ~/bin/make.cross
>  git checkout 4a06825839889cc1756d0dd8a52d6b1071ee0263
>  # save the attached .config to linux build tree
>  make.cross ARCH=mn10300 
> 
> All warnings (new ones prefixed by >>):
> 
>   In file included from include/linux/list.h:8:0,
>                    from include/linux/wait.h:6,
>                    from include/linux/fs.h:6,
>                    from include/linux/debugfs.h:18,
>                    from net/sunrpc/debugfs.c:7:
>   net/sunrpc/debugfs.c: In function 'fault_disconnect_write':
>   include/linux/kernel.h:723:17: warning: comparison of distinct pointer types lacks a cast
>     (void) (&_min1 == &_min2);  \
>                    ^
>>> net/sunrpc/debugfs.c:307:8: note: in expansion of macro 'min'
>     len = min(len, sizeof(buffer) - 1);
>           ^

I’m not sure why min_t() would be needed here. Both “len” and “sizeof”
are size_t. Does the subtraction change the type of its result?

I can send you a patch.


> vim +/min +307 net/sunrpc/debugfs.c
> 
>   291	fault_disconnect_read(struct file *filp, char __user *user_buf,
>   292			      size_t len, loff_t *offset)
>   293	{
>   294		char *buffer = (char *)filp->private_data;
>   295		size_t size;
>   296	
>   297		size = sprintf(buffer, "%u\n", rpc_inject_disconnect);
>   298		return simple_read_from_buffer(user_buf, len, offset, buffer, size);
>   299	}
>   300	
>   301	static ssize_t
>   302	fault_disconnect_write(struct file *filp, const char __user *user_buf,
>   303			       size_t len, loff_t *offset)
>   304	{
>   305		char buffer[16];
>   306	
>> 307		len = min(len, sizeof(buffer) - 1);
>   308		if (copy_from_user(buffer, user_buf, len))
>   309			return -EFAULT;
>   310		buffer[len] = '\0';
>   311		if (kstrtouint(buffer, 10, &rpc_inject_disconnect))
>   312			return -EINVAL;
>   313		return len;
>   314	}
>   315	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
> <.config.txt>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



