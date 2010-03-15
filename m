Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49312 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965819Ab0COXt7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Mar 2010 19:49:59 -0400
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute
 protocol (XATTR)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Casey Schaufler <casey@schaufler-ca.com>
Cc: Jamie Lokier <jamie@shareable.org>, Brad Boyer <flar@allandria.com>,
        James Morris <jmorris@namei.org>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org
In-Reply-To: <4B9EC2B9.3030800@schaufler-ca.com>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
	 <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org>
	 <20100309035932.GA14237@cynthia.pants.nu> <4B95E167.40306@schaufler-ca.com>
	 <20100309070444.GA18216@cynthia.pants.nu>
	 <20100309193545.GE11042@shareable.org> <4B971611.8030801@schaufler-ca.com>
	 <20100315031951.GU6491@shareable.org> <4B9DBAB0.5060500@schaufler-ca.com>
	 <20100315142803.GC15133@shareable.org>  <4B9EC2B9.3030800@schaufler-ca.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 15 Mar 2010 19:49:07 -0400
Message-ID: <1268696947.3155.6.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-03-15 at 16:28 -0700, Casey Schaufler wrote:

> You're missing something. Privilege semantics are different. The
> behavior of unlinked files is different. Locking is different. You
> are correct that in most cases it does not matter. We're not talking
> about the common case, we're talking about using xattrs to store
> information that is used to make security decisions. It is quite
> difficult to make security claims when an object can be accessed
> under two different sets of semantics.

I'm sorry. Exactly _how_ are you going to prevent files from being
accessed under more than one set of semantics under NFS? You have _no_
idea what kind of security mechanisms are implemented on the client.

All you can do is export a given set of security labels and hope...

Trond
