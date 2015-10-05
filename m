Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55570 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942AbbJELuX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2015 07:50:23 -0400
Subject: Re: [systemd-devel] [PATCH] gssd: Improve scalability by not waiting
 for child processes
To: Florian Weimer <fw@deneb.enyo.de>
References: <1443043250-25703-1-git-send-email-steved@redhat.com>
 <874mi7yrio.fsf@mid.deneb.enyo.de>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <561263FD.7030805@RedHat.com>
Date: Mon, 5 Oct 2015 07:50:21 -0400
MIME-Version: 1.0
In-Reply-To: <874mi7yrio.fsf@mid.deneb.enyo.de>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/04/2015 04:19 AM, Florian Weimer wrote:
> * Steve Dickson:
> 
>> +static void
>> +sig_child(int signal)
>> +{
>> +	int err;
>> +	pid_t pid;
>> +
>> +	/* Parent: just wait on child to exit and return */
>> +	do {
>> +		pid = wait(&err);
>> +	} while(pid == -1 && errno != -ECHILD);
>> +
>> +	if (WIFSIGNALED(err))
>> +		printerr(0, "WARNING: forked child was killed"
>> +			 "with signal %d\n", WTERMSIG(err));
>> +}
> 
> prinerr calls vfprintf or vsyslog.  Neither is safe to use in signal
> handlers, so you need to log this message in some other way.
Good point... but this patch was self NAK-ed due to it leaving
zombie processes during my testing.

steved.

