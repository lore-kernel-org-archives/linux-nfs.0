Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29516 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752505AbdJ3PUt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Oct 2017 11:20:49 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: init_net in restart_grace()
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org
Message-ID: <4221b3fe-39ec-0108-3db5-aaa410c1f63c@virtuozzo.com>
Date: Mon, 30 Oct 2017 18:20:45 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

restart_grace() still use hardcoded init_net.
It can cause to "list_add double add" in following scenario:

1) nfsd and lockd was started in several net namespaces
2) nfsd in init_net was stopped (lockd was not stopped because
 it have users from another net namespaces)
3) lockd got signal, called restart_grace() -> set_grace_period() 
 and enabled lock_manager in hardcoded init_net.
4) nfsd in init_net is started again,
its lockd_up() calls set_grace_period() and tries to add lock_manager
into init_net 2nd time.

I do not understand how to fix this problem correctly.

We can:
1) remove per-netns calls in restart_grace().
However it was worked for init-net-only case for ages,
and I afraid users of this functionality will object.

2) we can somehow provide reference to net namespace of process submitted handled signal
and handle pointed net namespace only. 
However this time it isn't clear for me how to do it.

3) we can call per-netns operations for all existing net namespaces
However I'm not sure is it expected behaviour.
Also I afraid it can be racy with creation/destroy of net namespaces.

4) we can make lockd kernel thraad per net_ns, like nfsd.
However this solution looks too heavy for this problem.

Could you please advise some other solution?

Thank you,
	Vasily Averin
