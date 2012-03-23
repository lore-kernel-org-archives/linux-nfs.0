Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754163Ab2CWQjU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Mar 2012 12:39:20 -0400
Date: Fri, 23 Mar 2012 17:30:46 +0100
From: Oleg Nesterov <oleg@redhat.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
        akpm@linux-foundation.org, rjw@sisk.pl, keyrings@linux-nfs.org,
        linux-security-module@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Trond.Myklebust@netapp.com, sbhamare@panasas.com, dhowells@redhat.com,
        eparis@redhat.com, srivatsa.bhat@linux.vnet.ibm.com,
        kay.sievers@vrfy.org, jmorris@namei.org, ebiederm@xmission.com,
        gregkh@linuxfoundation.org, rusty@rustcorp.com.au, tj@kernel.org,
        rientjes@google.com
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new
	call_usermodehelper_timeout()API
Message-ID: <20120323163046.GA16562@redhat.com>
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com> <4F6A92FC.6060702@panasas.com> <20120322142758.GA12370@redhat.com> <4F6B789C.8020201@panasas.com> <201203230716.GFE32712.StOJOVFHMQOFFL@I-love.SAKURA.ne.jp> <4F6C0092.1010901@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F6C0092.1010901@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/22, Boaz Harrosh wrote:
>
> On 03/22/2012 03:16 PM, Tetsuo Handa wrote:
>
> > I think you should use a fork()ed wrapper in userspace for implementing
> > timeout.
>
> I did that actually. But I would like not to be dependent on it. I would like
> the Kernel to be independent and simple timeout and recover,

Tetsuo, Boaz, since I do not understand the problem space, I am not
going to discuss the "do we need the timeout" thing.

But, just in case, perhaps there is no need to change kmod.c ? I do
not know if it works for you, but you can simply do something like


	struct kill_work {
		struct delayed_work work;
		struct pid *pid;
	};

	void kill_work_func(struct work_struct *_work)
	{
		struct kill_work *work = container_of(_work, struct kill_work, work);
		kill_pid(work->pid, SIGKILL);
		put_pid(work->pid);
		kfree(work);
	}

	int unh_setup_timeout(struct subprocess_info *info, struct cred *new)
	{
		struct kill_work *work = kmalloc(sizeof(struct kill_work));
		if (!work)
			return -ENOMEM;

		INIT_WORK(&work->work, kill_work_func);
		work->pid = get_pid(task_pid(current));
		schedule_delayed_work(&work->work, (long)info->data);

		return 0;
	}

Now you can do

	call_usermodehelper_fns(init => unh_setup_timeout,
				data => (void*)timeout);

Oleg.

