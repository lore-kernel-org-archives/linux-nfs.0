Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752529AbaJBUIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Oct 2014 16:08:25 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s92K8OLI019506
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 2 Oct 2014 16:08:24 -0400
Date: Thu, 2 Oct 2014 16:08:22 -0400
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] Centralize dependencies on the auth unit.
Message-ID: <20141002160822.0fa80208@willson.usersys.redhat.com>
In-Reply-To: <542DA720.5020002@RedHat.com>
References: <542AC20B.9040509@redhat.com>
	<1412091888-32220-1-git-send-email-simo@redhat.com>
	<542DA720.5020002@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 02 Oct 2014 15:27:28 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> I begrudgingly commit this because when gssproxy is install
> the NFS client will *always* start it, which is
> a bug in gssproxy... IMHO... If a daemon is not needed
> it shouldn't start up... similar to how the gss daemons work.

I agree with you that when a service is not needed it should not start,
but it is tricky to automatically figure, from init scripts, if it is
needed, because gssproxy has is a general purpose tool that can be used
for other user-space related uses and not server NFS at all.

On the bright side an admin that is annoyed by it being started can
simply mask it:
# systemctl mask gssproxy.service
or even uninstall the package for now.


Now the reason gssproxy.service is always started seem to be that
although auth-rpcgss-module.service is not going to start and it set to
start Before all its Wants ... those Wants seem to be processed and
started anyway.

I think this may be seen as a bug, we'll probably need to ask upstream
if it is or if there is some other clever workaround to Want another
unit files conditioned to whether the unit is going to be started at
runtime.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York
