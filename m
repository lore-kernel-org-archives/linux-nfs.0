Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f43.google.com ([209.85.160.43]:64288 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbaDREDt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 00:03:49 -0400
Received: by mail-pb0-f43.google.com with SMTP id um1so1076426pbc.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Apr 2014 21:03:49 -0700 (PDT)
Message-ID: <5350A406.5060700@gmail.com>
Date: Fri, 18 Apr 2014 12:03:18 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Clear cached acl after setting a zero-length default
 posix acl:
References: <534FCD13.303@gmail.com> <20140417143634.GA20857@infradead.org>
In-Reply-To: <20140417143634.GA20857@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014/4/17 22:36, Christoph Hellwig wrote:
> On Thu, Apr 17, 2014 at 08:46:11PM +0800, Kinglong Mee wrote:
>> After setting ACL for directory, I got two problems that caused
>> by the cached zero-length default posix acl.
>>
>> This patch just clears the cached zero-length default posix acl
>> after setting.
>>
>> First problem:
>> # nfs4_setfacl -s A::OWNER@:RWX /mnt/123/; touch /mnt/123/test
>> ............ hang ...........
>
> Nfsd must not call forget_cached_acl, that's the filesystems job.
> I think the right fix is to make sure nfsd4_set_nfs4_acl calls ->set_acl
> with a NULL ACL structure if there are no entries.

Thanks for your advice.

>
> Btw, it would be really good if we kept tests like this as a regression
> test suite.  Is there one for NFS already?  If not we could add
> nfs-specific tests to xfstests as well.

I found one at 
http://www.citi.umich.edu/projects/asci/icsi-alpha/acl-test-20060929.tar.gz 
, but it does not work on Fedora 20 without the following patch.

thanks,
Kinglong Mee

 From 6fb72997379ef84fdbcf4938dc68a6ef7c4f1f00 Mon Sep 17 00:00:00 2001
From: Kinglong Mee <kinglongmee@gmail.com>
Date: Thu, 17 Apr 2014 19:57:15 +0800
Subject: [PATCH] nfs4_set_acl has delete l/s/f flags, using r/w/a

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
  runtests | 16 ++++++++--------
  1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/runtests b/runtests
index 25d4a9d..d0eeedd 100755
--- a/runtests
+++ b/runtests
@@ -79,30 +79,30 @@ $r $u $prog setacl "$a":rwaxdnNtTcoy $file $file

  # Create a test directory, give owner all permissions
  mkdir $dir
-nfs4_setfacl -s "$a":xlfsDnNtTcCoy $dir
+nfs4_setfacl -s "$a":xrwaDnNtTcCoy $dir

  # Remove permissions one at a time, check that they're really gone

-$r $u $prog creat "$a":xlsDnNtTcCoy $dir $dir/$file
-$r $u $prog listdir "$a":xsfDnNtTcCoy $dir $dir
-$r $u $prog mkdir "$a":xlfDnNtTcCoy $dir $dir/$dir
+$r $u $prog creat "$a":xraDnNtTcCoy $dir $dir/$file
+$r $u $prog listdir "$a":xawDnNtTcCoy $dir $dir
+$r $u $prog mkdir "$a":xrwDnNtTcCoy $dir $dir/$dir

  # Create a file for lookup and delete tests

-nfs4_setfacl -s A::OWNER@:xlfsDnNtTcCoy $dir
+nfs4_setfacl -s A::OWNER@:xrwaDnNtTcCoy $dir
  touch $dir/$file
  if (! -f $dir/$file) then
    echo "can't create $testdir/$dir/$file for testing"
  endif

-$r $u $prog lookup "$a":lfsDnNtTcCoy $dir $dir/$file
+$r $u $prog lookup "$a":rwaDnNtTcCoy $dir $dir/$file

  # Delete test: first have to put back lookup ("x") rights,
  # then remove "d", then "D"
-nfs4_setfacl -s A::OWNER@:xlfsDnNtTcCoy $dir
+nfs4_setfacl -s A::OWNER@:xrwaDnNtTcCoy $dir
  nfs4_setfacl -s "$a":rwaxnNtTcCoy $dir/$file
  if ($status != 0) then
    exit 1
  endif

-$r $u $prog rm "$a":xlfsnNtTcCoy $dir $dir/$file
+$r $u $prog rm "$a":xrwanNtTcCoy $dir $dir/$file
-- 
1.9.0

