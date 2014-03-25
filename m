Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47769 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751907AbaCYKlX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Mar 2014 06:41:23 -0400
Message-ID: <53315D4C.9000407@RedHat.com>
Date: Tue, 25 Mar 2014 06:41:16 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: David Howells <dhowells@redhat.com>
CC: Benjamin Coddington <bcodding@uvm.edu>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
References: <5330C65B.6010904@RedHat.com> <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu> <53308CD4.9020307@RedHat.com> <21458.1395739746@warthog.procyon.org.uk>
In-Reply-To: <21458.1395739746@warthog.procyon.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/25/2014 05:29 AM, David Howells wrote:
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>> The reason the default is "id_resolver" is because the
>> is the name of the key ring defined in id_resolver.conf
>> is id_resolver. Now how that is translated into ".id_resolver"
>> in /proc/keys is not clear.... 
> 
> Where in /etc/request-key.d/id_resolver.conf does it mention the name of a
> keyring?
> 
> 	create    id_resolver    *         *    /usr/sbin/nfsidmap %k %d
I though "id_resolver" was the name. 

> 
> Match it against this line from request-key.conf:
> 
> 	#OP     TYPE    DESCRIPTION     CALLOUT INFO    PROGRAM ARG1 ARG2 ARG3 ...
I should probably document this in request-key.conf.

> 
> The "id_resolver" here is the name of the *key type* to be matched for that
> line.  There is nothing here to do with keyrings.
Thanks for the clarification...

steved.
 
> 
> David
> 
