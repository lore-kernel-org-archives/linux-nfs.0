Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33292 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410Ab1GHGF3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jul 2011 02:05:29 -0400
Content-Type: text/plain; charset=us-ascii
Message-ID: <19990.40467.487035.962976@regina.usersys.redhat.com>
Date: Fri, 8 Jul 2011 16:05:07 +1000
From: Max Matveev <makc@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: NFS/TCP timeout sequence
In-Reply-To: <1310048213.3863.37.camel@lade.trondhjem.org>
References: <19989.27202.793003.725608@regina.usersys.redhat.com>
	<1310046439.3863.30.camel@lade.trondhjem.org>
	<5F749FAD-94B0-4D9D-84F6-F7D9662A1CF6@oracle.com>
	<1310048213.3863.37.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 07 Jul 2011 10:16:53 -0400, Trond Myklebust wrote:

> Anyway, why shouldn't we back off if the server is failing to respond?

Wasn't it the no-backoff/drop-connection approach what Mike Eisler was
advocating back in '06 during Connectathon?

http://www.connectathon.org/talks06/eisler.pdf

I think this was the trigger to go from exponential backoff to linear.

max
