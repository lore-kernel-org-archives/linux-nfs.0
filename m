From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 1/4] nfs-utils: introduce new statd implementation (1st part)
Date: Wed, 5 Aug 2009 18:24:04 -0400
Message-ID: <D503383F-3D52-4F93-B850-AFE84316435C@oracle.com>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net> <20090805144540.12866.22084.stgit@matisse.1015granger.net> <20090805174811.GB9944@fieldses.org> <DBAD3130-0633-414A-914B-CC2F15ABB219@oracle.com> <20090805181545.GF9944@fieldses.org> <7330021D-C95A-463D-8D18-29453EF185BC@oracle.com> <1249507356.5428.11.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:63599 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbZHEWYf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 18:24:35 -0400
In-Reply-To: <1249507356.5428.11.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 5, 2009, at 5:22 PM, Trond Myklebust wrote:
> On Wed, 2009-08-05 at 14:26 -0400, Chuck Lever wrote:
>> sqlite3 doesn't do anything special under the covers.  It uses only
>> POSIX file access and locking calls, as far as I know.  So I think
>> hosting /var on most well-behaved clustering file systems won't have
>> any problem with this arrangement.
>
> So we're basically introducing a dependency on a completely new  
> library
> that will have to be added to boot partitions/nfsroot/etc, and we have
> no real reason for doing it other than because we want to move from
> using sync() to fsync()?
>
> Sounds like a NACK to me...

Which library are you talking about, libsqlite3 or libtirpc?  Because  
NEITHER of those is in /lib.

In any event, it's not just sync(2) that is a problem.  sync(2) by  
itself is a boot performance problem, but it's the combination of  
rename and sync that is known to be especially unreliable during  
system crashes.  Statd, being a crash monitor, shouldn't depend on  
rename/sync to maintain persistent data in the face of system  
instability.  I'd call that a real reason to use something more robust.

Can we try to be a little more constructive, please?  Asking the list  
(which includes distributors, who actually have to worry about such  
things) whether this would be a problem is significantly less abrasive  
then just saying "NACK" outright.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
