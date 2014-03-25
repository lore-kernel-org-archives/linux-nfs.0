Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46212 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbaCYJ3Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 05:29:16 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <5330C65B.6010904@RedHat.com>
References: <5330C65B.6010904@RedHat.com> <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu> <53308CD4.9020307@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: dhowells@redhat.com, Benjamin Coddington <bcodding@uvm.edu>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
Date: Tue, 25 Mar 2014 09:29:06 +0000
Message-ID: <21458.1395739746@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson <SteveD@redhat.com> wrote:

> The reason the default is "id_resolver" is because the
> is the name of the key ring defined in id_resolver.conf
> is id_resolver. Now how that is translated into ".id_resolver"
> in /proc/keys is not clear.... 

Where in /etc/request-key.d/id_resolver.conf does it mention the name of a
keyring?

	create    id_resolver    *         *    /usr/sbin/nfsidmap %k %d

Match it against this line from request-key.conf:

	#OP     TYPE    DESCRIPTION     CALLOUT INFO    PROGRAM ARG1 ARG2 ARG3 ...

The "id_resolver" here is the name of the *key type* to be matched for that
line.  There is nothing here to do with keyrings.

David
