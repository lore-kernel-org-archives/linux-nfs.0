Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11768 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754602Ab1BYAhg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 19:37:36 -0500
Subject: Re: stat family function problem (php file_exists)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: larith <larith@go2.pl>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <3c95bae3.61f80ace.4d666374.d4ebc@go2.pl>
References: <3c95bae3.61f80ace.4d666374.d4ebc@go2.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Feb 2011 16:37:34 -0800
Message-ID: <1298594254.4606.6.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-02-24 at 14:56 +0100, larith wrote: 
> Hi
> 
> I have one nfs server mounted on 2 clients. If I check on client2 if a file exists, then after creating this file on client2 is is not immediately visible to file_exist() function on client2. it was only after some time. how to fix this ?

1) Use open() instead of stat()

or

2) Use the -olookupcache=  mount option (see 'man 5 nfs').

Trond

> client1:/mnt/storage0/test# cat a.php
> <?php
> 
> if (file_exists ($argv[1])) {
>     echo "1\n";
> } else {
>     echo "0\n";
> }

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

