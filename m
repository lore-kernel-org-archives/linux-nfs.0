Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:49949 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932252AbdJ3RUK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Oct 2017 13:20:10 -0400
Received: by mail-qt0-f178.google.com with SMTP id k31so17338085qta.6
        for <linux-nfs@vger.kernel.org>; Mon, 30 Oct 2017 10:20:09 -0700 (PDT)
Message-ID: <1509384007.5412.43.camel@redhat.com>
Subject: Re: init_net in restart_grace()
From: Jeff Layton <jlayton@redhat.com>
To: Vasily Averin <vvs@virtuozzo.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Stanislav Kinsburskiy <skinsbursky@virtuozzo.com>
Date: Mon, 30 Oct 2017 13:20:07 -0400
In-Reply-To: <4221b3fe-39ec-0108-3db5-aaa410c1f63c@virtuozzo.com>
References: <4221b3fe-39ec-0108-3db5-aaa410c1f63c@virtuozzo.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-10-30 at 18:20 +0300, Vasily Averin wrote:
> restart_grace() still use hardcoded init_net.
> It can cause to "list_add double add" in following scenario:
> 
> 1) nfsd and lockd was started in several net namespaces
> 2) nfsd in init_net was stopped (lockd was not stopped because
>  it have users from another net namespaces)
> 3) lockd got signal, called restart_grace() -> set_grace_period() 
>  and enabled lock_manager in hardcoded init_net.
> 4) nfsd in init_net is started again,
> its lockd_up() calls set_grace_period() and tries to add lock_manager
> into init_net 2nd time.
> 
> I do not understand how to fix this problem correctly.
> 
> We can:
> 1) remove per-netns calls in restart_grace().
> However it was worked for init-net-only case for ages,
> and I afraid users of this functionality will object.
> 
> 2) we can somehow provide reference to net namespace of process submitted handled signal
> and handle pointed net namespace only. 
> However this time it isn't clear for me how to do it.
>
> 3) we can call per-netns operations for all existing net namespaces
> However I'm not sure is it expected behaviour.
> Also I afraid it can be racy with creation/destroy of net namespaces.
> 
> 4) we can make lockd kernel thraad per net_ns, like nfsd.
> However this solution looks too heavy for this problem.
> 
> Could you please advise some other solution?
> 
> Thank you,
> 	Vasily Averin

The problem seems to be that list_add in locks_start_grace. It seems
like we only want to do that list_add if list_empty(&lm->list) is true.
We already do a list_del_init when removing from grace_list, and it
looks like both users of this API initialize their lists properly.

Is that enough of a fix or am I missing the bigger picture?
-- 
Jeff Layton <jlayton@redhat.com>
