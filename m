Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mgwym02.jp.fujitsu.com ([211.128.242.41]:30043 "EHLO
	mgwym02.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbcBSDIt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Feb 2016 22:08:49 -0500
Subject: Re: call_usermodehelper in containers
To: "Eric W. Biederman" <ebiederm@xmission.com>, Ian Kent <raven@themaw.net>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
 <20131112004703.GB15377@kroah.com>
 <20131112061201.04cf25ab@tlielax.poochiereds.net>
 <528226EC.4050701@parallels.com>
 <20131112083043.0ab78e67@tlielax.poochiereds.net>
 <5285FA0A.2080802@parallels.com> <871u2incyo.fsf@xmission.com>
 <20131118172844.GA10005@redhat.com> <1455149857.2903.9.camel@themaw.net>
 <8737sq4teb.fsf@x220.int.ebiederm.org> <56C53DE3.1070108@jp.fujitsu.com>
 <1455777387.3188.24.camel@themaw.net> <1455781033.2908.5.camel@themaw.net>
 <87r3g9ychc.fsf@x220.int.ebiederm.org>
Cc: Oleg Nesterov <oleg@redhat.com>,
        Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Jeff Layton <jlayton@redhat.com>, Greg KH <gregkh@linuxfoundation.org>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, devel@openvz.org, bfields@fieldses.org,
        bharrosh@panasas.com,
        Linux Containers <containers@lists.linux-foundation.org>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <56C68714.2000900@jp.fujitsu.com>
Date: Fri, 19 Feb 2016 12:08:04 +0900
MIME-Version: 1.0
In-Reply-To: <87r3g9ychc.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset=iso-2022-jp
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2016/02/19 5:45, Eric W. Biederman wrote: 
> Personally I am a fan of the don't be clever and capture a kernel thread
> approach as it is very easy to see you what if any exploitation
> opportunities there are.  The justifications for something more clever
> is trickier.  Of course we do something that from this perspective would
> be considered ``clever'' today with kthreadd and user mode helpers.
> 

I read old discussion....let me allow clarification  to create a helper kernel thread 
to run usermodehelper with using kthreadd.

0) define a trigger to create an independent usermodehelper environment for a container.
   Option A) at creating some namespace (pid, uid, etc...)
   Option B) at creating a new nsproxy
   Option C).at a new systemcall is called or some sysctl, make_private_usermode_helper() or some,
  
  It's expected this should be triggered by init process of a container with some capability.
  And scope of the effect should be defined. pid namespace ? nsporxy ? or new namespace ?

1) create a helper thread.
   task = kthread_create(kthread_work_fn, ?, ?, "usermodehelper")
   switch task's nsproxy to current.(swtich_task_namespaces())
   switch task's cgroups to current (cgroup_attach_task_all())
   switch task's cred to current.
   copy task's capability from current
   (and any other ?)
   wake_up_process()
   
   And create a link between kthread_wq and container.

2) modify call_usermodehelper() to use kthread_worker
....

It seems the problem is which object container private user mode helper should be tied to.

Regards,
-Kame
