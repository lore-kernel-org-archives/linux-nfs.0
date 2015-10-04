Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from albireo.enyo.de ([46.237.207.196]:47679 "EHLO albireo.enyo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247AbbJDIo5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 Oct 2015 04:44:57 -0400
From: Florian Weimer <fw@deneb.enyo.de>
To: Steve Dickson <steved@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Systemd Mailing List <systemd-devel@lists.freedesktop.org>
Subject: Re: [systemd-devel] [PATCH] gssd: Improve scalability by not waiting for child processes
References: <1443043250-25703-1-git-send-email-steved@redhat.com>
Date: Sun, 04 Oct 2015 10:19:59 +0200
In-Reply-To: <1443043250-25703-1-git-send-email-steved@redhat.com> (Steve
	Dickson's message of "Wed, 23 Sep 2015 17:20:50 -0400")
Message-ID: <874mi7yrio.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Steve Dickson:

> +static void
> +sig_child(int signal)
> +{
> +	int err;
> +	pid_t pid;
> +
> +	/* Parent: just wait on child to exit and return */
> +	do {
> +		pid = wait(&err);
> +	} while(pid == -1 && errno != -ECHILD);
> +
> +	if (WIFSIGNALED(err))
> +		printerr(0, "WARNING: forked child was killed"
> +			 "with signal %d\n", WTERMSIG(err));
> +}

prinerr calls vfprintf or vsyslog.  Neither is safe to use in signal
handlers, so you need to log this message in some other way.

Florian
