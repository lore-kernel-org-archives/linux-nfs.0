Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:14820 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752217Ab1LSRZ7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Dec 2011 12:25:59 -0500
Message-ID: <4EEF7364.8000407@parallels.com>
Date: Mon, 19 Dec 2011 21:24:52 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Eric W. Biederman" <ebiederm@xmission.com>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>	<20111214104449.3991.61989.stgit@localhost6.localdomain6>	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com> <m1pqfkecw0.fsf@fess.ebiederm.org>
In-Reply-To: <m1pqfkecw0.fsf@fess.ebiederm.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

19.12.2011 20:37, Eric W. Biederman пишет:
> Stanislav Kinsbursky<skinsbursky@parallels.com>  writes:
>
> Doing that independently of the rest of the sysctls is pretty horrible
> and confusing to users.   What I am planning might suit your needs and
> if not we need to talk some more about how to get the vfs to do
> something reasonable.
>

Ok, Eric. Would be glad to discuss your sysctls plans.
But actually you already know my needs: I would like to make sysctls work in the 
way like sysfs does: i.e. content of files depends on mount maker - not viewer.

-- 
Best regards,
Stanislav Kinsbursky
