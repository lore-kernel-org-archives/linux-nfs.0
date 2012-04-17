Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932312Ab2DQNqH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 09:46:07 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q3HDk7Fa017117
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Apr 2012 09:46:07 -0400
Subject: Re: [PATCH 0/5] [RFC] Add support for new upcall mechanism for nfsd
From: Simo Sorce <simo@redhat.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1334669948-4156-1-git-send-email-simo@redhat.com>
References: <1334669948-4156-1-git-send-email-simo@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 17 Apr 2012 09:46:05 -0400
Message-ID: <1334670365.16658.179.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-04-17 at 09:39 -0400, Simo Sorce wrote:
> This patchset implements a new upcall mechanism that uses the sunrpc client
> to talk to gssproxy[1], a new userspace daemon to handle gssapi operations on
> behalf of other processes on the system.
> 
> The main driver for this new mechanism is to overcome limitations with the
> current daemon and upcall. The current code cannot handle tickets larger than
> approximatively 2k and cannot handle large user credentials set to be set in
> the kernel.
> 
> These patches have been tested against the development version of gssproxy
> tagged as kernel_v0.1 in the master repo[2].
> 
> I have tested walking into mountpoints using tickets artificially pumped up to
> 64k and the user is properly authorized, after the accept_se_context call is
> performed through the new upcall mechanism and gssproxy.
> 
> The gssproxy has the potential of handling also init_sec_context calls, but at
> the moment the only targeted system is nfsd.

Sorry, forgot to add the [1] and [2] references before sending, here
they are:
[1] https://fedorahosted.org/gss-proxy/
[2] http://git.fedorahosted.org/git/?p=gss-proxy.git

Simo.


-- 
Simo Sorce * Red Hat, Inc * New York

