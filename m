Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 310EFC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:55:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E463C21736
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 23:55:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tycho-ws.20150623.gappssmtp.com header.i=@tycho-ws.20150623.gappssmtp.com header.b="Z/7b/1vA"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729962AbfBSXzl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 18:55:41 -0500
Received: from mail-yb1-f195.google.com ([209.85.219.195]:44786 "EHLO
        mail-yb1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728652AbfBSXzk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 18:55:40 -0500
Received: by mail-yb1-f195.google.com with SMTP id j85so5544348ybg.11
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 15:55:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=tycho-ws.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XmfykJFWMdzt50aQZr96YqLCUVrpFtYe1zYWBcFZzcA=;
        b=Z/7b/1vAoATLYB980TMrZnS7a9RZhkaOR+kZaRlTSKJ2TW2hKAF1Drh3EQ4Ly0Glgc
         xs0V5+JSQ7F0m8mn2l+d/+4qIGgNI/fUN81yfRnBcs69K2Psmy9VjGESBckZHyE2kwxB
         xRm3tMIngV4zq82LrVYsILkQkvRzAHxXgKwbtuY8YBc2gZgmZ0iyY68dauf+YQsmSibJ
         x3rdISbdn9/77fMX5S7SuazmkcDnt9j9omFPPdlyA3/L/y241YHXK0vE/eNLsmmEKCBf
         UWX7v0pSGDjEDkVVhHXwdOwIZUQrJK8wyi1dCBPG3jsNP42fJ1HiQ1lvP6YEABIzbHhm
         LLCg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=XmfykJFWMdzt50aQZr96YqLCUVrpFtYe1zYWBcFZzcA=;
        b=WgtNfWdDMOc8s8V+aM2Sp4HrIwsu7KKloHPW/onKuzZJgt1RHi6r4Bn5o6puF476SL
         IJt7I1BJBTG3s/pTanGS3onKW3yNO+FT864Tn3h0a0EyR743RaVZ2TauSB0qv83fvwWb
         s8abB1WXTYdHVmtZhnEmzYEuOfuTSViWkbQ/iey8RkAduzxeKuT75V9nM+DnHd2lOFcL
         /43xtiKhulfWcFT5oCEhJjursbpUN6dDhh9Bh8CGpagSIieQW8Xf/44TxN8aoU9umgUl
         AMbKEd194SACbtwejT3GZvg+oK5BsWl7kQRre1DrzsOhN+8mpCits/Ie8DoppfrXw54p
         HhSw==
X-Gm-Message-State: AHQUAuZZHlhfhYA7sgc3cMyOv8XfrwDsR67RKMt8wAHen9N8T0fQvQ1d
        jeW6i8524zYj3Hy1pVVcbUNuJg==
X-Google-Smtp-Source: AHgI3Ia2i9jHTYEQ7iOijMe8HCPEysNc4k8d73BEpsZQ5AC7eUJ2apQHuYie8xBVEi4zutUdVt+6LQ==
X-Received: by 2002:a5b:501:: with SMTP id o1mr25411431ybp.85.1550620539905;
        Tue, 19 Feb 2019 15:55:39 -0800 (PST)
Received: from cisco ([128.107.241.177])
        by smtp.gmail.com with ESMTPSA id v9sm7655589ywe.59.2019.02.19.15.55.38
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 15:55:39 -0800 (PST)
Date:   Tue, 19 Feb 2019 16:55:37 -0700
From:   Tycho Andersen <tycho@tycho.ws>
To:     David Howells <dhowells@redhat.com>
Cc:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org, linux-security-module@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, rgb@redhat.com,
        linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 02/27] containers: Implement containers as kernel
 objects
Message-ID: <20190219235537.GC5274@cisco>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
 <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <155024685321.21651.1504201877881622756.stgit@warthog.procyon.org.uk>
User-Agent: Mutt/1.10.1 (2018-07-13)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Feb 15, 2019 at 04:07:33PM +0000, David Howells wrote:
> ==================
> FUTURE DEVELOPMENT
> ==================
> 
>  (1) Setting up the container.
> 
>      A container would be created with, say:
> 
> 	int cfd = container_create("fred", CONTAINER_NEW_EMPTY_FS_NS);
> 

...

>      Further mounts can be added by:
> 
> 	move_mount(mfd, "", cfd, "proc", MOVE_MOUNT_F_EMPTY_PATH);
> 

...

>  (2) Starting the container.
> 
>      Once all modifications are complete, the container's 'init' process
>      can be started by:
> 
> 	fork_into_container(int cfd);
> 
>      This precludes further external modification of the mount tree within
>      the container.

Is there a technical reason for this? In particular, there are some
container runtimes that do this today via clever use of bind mounts
and MS_MOVE, for things like dynamically attaching volumes. It would
be useful to be able to mount things into the container after the
fact.

>  (3) Waiting for the container to complete.
> 
>      The container fd can then be polled to wait for init process therein
>      to complete and the exit code collected by:
> 
> 	container_wait(int container_fd, int *_wstatus, unsigned int wait,
> 		       struct rusage *rusage);
> 
>      The container and everything in it can be terminated or killed off:
> 
> 	container_kill(int container_fd, int initonly, int signal);
> 
>      If 'init' dies, all other processes in the container are preemptively
>      SIGKILL'd by the kernel.

Isn't this essentially how the pid ns works today? I'm not sure what
the container fd offers here (of course if it lands, then having the
same semantics makes sense).

>  (6) Running different LSM policies by container.  This might particularly
>      make sense with something like Apparmor where different path-based
>      rules might be required inside a container to inside the parent.

Apparmor supports this today, as long as the host is also running
Apparmor. For the more general case, Casey (and others) have been
working on LSM stacking for a long time.

Tycho
