Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:46169 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754952Ab0KJSvg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Nov 2010 13:51:36 -0500
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id oAAIJJcb022298
	for <linux-nfs@vger.kernel.org>; Wed, 10 Nov 2010 23:49:19 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAAIpXD2852190
	for <linux-nfs@vger.kernel.org>; Thu, 11 Nov 2010 00:21:33 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAAIpXvL002849
	for <linux-nfs@vger.kernel.org>; Thu, 11 Nov 2010 05:51:33 +1100
From: "Aneesh Kumar K. V" <aneesh.kumar@linux.vnet.ibm.com>
To: Trond Myklebust <trond.myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv4 ACL set and inode attribute cache
In-Reply-To: <m3hbfpvz0k.fsf@linux.vnet.ibm.com>
References: <m3hbfpvz0k.fsf@linux.vnet.ibm.com>
Date: Thu, 11 Nov 2010 00:21:27 +0530
Message-ID: <m3eiatvwpc.fsf@linux.vnet.ibm.com>
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 10 Nov 2010 23:31:31 +0530, Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com> wrote:
> 
> Hi,
> 
> I guess we are not marking the inode attribute as invalid when we set
> the ACL value. For ex:
> 
> /d# mkdir sub3
> /d# ls -dl sub3
> drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> /d# nfs4_setfacl -s A:fd:EVERYONE@:rwax sub3
> /d# ls -dl sub3
> drwxr-xr-x 2 root root 4096 Nov 10 17:56 sub3
> /d# 
> 
> 
> On the server i have the mode bits as
> /d# ls -dl sub3
> drwxrwxrwx 2 root root 4096 Nov 10 17:56 sub3
> /d# 

We also have similar issue other way round. ie setting the mode bits
don't result in ACL values being invalidated. But a second request get
the right value of ACL as show below.

/d# nfs4_getfacl  x
A::OWNER@:rw
A::GROUP@:rw
A::EVERYONE@:r
/d# chmod 600 x
/d# nfs4_getfacl  x
A::OWNER@:rw
A::GROUP@:rw
A::EVERYONE@:r
/d#

Expected value is

/d# nfs4_getfacl  x
A::OWNER@:rw

-aneesh
