Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:40467 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756451Ab0ITPUd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 11:20:33 -0400
Subject: Re: Should we be aggressively invalidating cache when using -onolock?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <981484.56.1284995756178.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
Date: Mon, 20 Sep 2010 11:19:57 -0400
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Message-Id: <B8845252-0CD5-45AF-B29D-52C45D295BBF@oracle.com>
References: <981484.56.1284995756178.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
To: Sachin Prabhu <sprabhu@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 20, 2010, at 11:15 AM, Sachin Prabhu wrote:

> ----- "Chuck Lever" <chuck.lever@oracle.com> wrote:
>> It also seems to me that if RHEL 4 is _not_ invalidating on lock, then
>> it is not working as designed.  AFAIK the Linux NFS client has always
>> invalidated a file's data cache on lock.  Did I misread something?
>> 
> 
> The flock support for NFS was only implemented in the 2.6.12 kernel. Hence on the RHEL 4 kernel ie 2.6.9 nfs_file_operations->flock is NULL and any flock operations performed by the application was only applicable on that node. No part of the NFS client code was executed for the flock() operation. 

I see, so in RHEL 4, the original fcntl(2) invalidate-on-lock behavior is working correctly, but flock(2) is not, since flock(2) wasn't supported in 2.6.9's NFS client.  Correct?

-- 
chuck[dot]lever[at]oracle[dot]com




