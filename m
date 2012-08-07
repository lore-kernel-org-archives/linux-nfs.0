Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:50397 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756042Ab2HGUKw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Aug 2012 16:10:52 -0400
Message-ID: <50217649.6010402@netapp.com>
Date: Tue, 07 Aug 2012 16:10:49 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: nfs4 mounts failing with 3.6.0-rc1
References: <20120804000819.GB25558@fieldses.org> <20120803220039.743fe1f0@corrin.poochiereds.net> <20120804190104.GA2135@fieldses.org> <20120807130932.79625d7e@tlielax.poochiereds.net> <20120807194250.GB22532@fieldses.org> <50217035.5010304@netapp.com> <20120807195703.GC22532@fieldses.org>
In-Reply-To: <20120807195703.GC22532@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/07/2012 03:57 PM, J. Bruce Fields wrote:
> On Tue, Aug 07, 2012 at 03:44:53PM -0400, Bryan Schumaker wrote:
>> On 08/07/2012 03:42 PM, J. Bruce Fields wrote:
>>> On Tue, Aug 07, 2012 at 01:09:32PM -0400, Jeff Layton wrote:
>>>> On Sat, 4 Aug 2012 15:01:04 -0400
>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>
>>>>> On Fri, Aug 03, 2012 at 10:00:39PM -0400, Jeff Layton wrote:
>>>>>> On Fri, 3 Aug 2012 20:08:19 -0400
>>>>>> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>>>>
>>>>>>> I'm getting
>>>>>>>
>>>>>>> 	# mount -tnfs -onfsvers=4 pip1:/exports /mnt/
>>>>>>>
>>>>>>> (OK, admittedly that's with 3.6.0-rc1 + a few experimental patches, but
>>>>>>> I doubt they're related.)
>>>>>>>
>>>>>>> Also:
>>>>>>>
>>>>>>> 	[root@pip2 ~]# modprobe nfs4
>>>>>>> 	[root@pip2 ~]# lsmod|grep nfs4
>>>>>>> 	[root@pip2 ~]# 
>>>>>>>
>>>>>>> --b.
>>>>>>
>>>>>> I hit the same problem...
>>>>>>
>>>>>> Try removing /usr/lib/modprobe.d/nfs.conf (assuming you're running
>>>>>> Fedora).
>>>>>
>>>>> Oog, right.
>>>>>
>>>>> But, without testing--won't that make v4 mounts fail on older kernels?
>>>>
>>>> Actually, now that I look, this does not seem to break on older kernels
>>>> as long as you use a syntax like:
>>>>
>>>>     # mount -t nfs server:/export /mnt/point -o vers=4
>>>>
>>>> ...if, however you use a syntax like:
>>>>
>>>>     # mount -t nfs4 server:/export /mnt/point
>>>>
>>>> ...then it fails without the above file in place. I guess the question
>>>> we have to answer is: Do we want to continue to support the "-t nfs4"
>>>> mount syntax?
>>>
>>> I think you're right that we want to deprecate it.
>>>
>>> Though this is a bit of a harsh way to do it--would have been nice to
>>> have some transition period with a warning or something.
>>
>> I didn't expect this to be broken, both ways of mounting still work on my VMs so I expected them to work for everybody else too.
> 
> Huh.  Just checked on an old kernel without an "alias nfs4 nfs" in
> modprobe configuration, and sure enough I get "No such device".
> 
> Maybe you have some initscripts or something else that's loading the
> nfs module for you before the mount?

My nfs-common daemon script loads sunrpc, nfs and nfsd but not nfs2, nfs3 or nfs4.

Could we rename the module to avoid the alias name collision?  Something like this (untested) maybe?



diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
index 8bf3a3f..b7db608 100644
--- a/fs/nfs/Makefile
+++ b/fs/nfs/Makefile
@@ -12,19 +12,19 @@ nfs-$(CONFIG_ROOT_NFS)      += nfsroot.o
 nfs-$(CONFIG_SYSCTL)   += sysctl.o
 nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
 
-obj-$(CONFIG_NFS_V2) += nfs2.o
-nfs2-y := nfs2super.o proc.o nfs2xdr.o
+obj-$(CONFIG_NFS_V2) += nfsv2.o
+nfsv2-y := nfs2super.o proc.o nfs2xdr.o
 
-obj-$(CONFIG_NFS_V3) += nfs3.o
-nfs3-y := nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
-nfs3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
+obj-$(CONFIG_NFS_V3) += nfsv3.o
+nfsv3-y := nfs3super.o nfs3client.o nfs3proc.o nfs3xdr.o
+nfsv3-$(CONFIG_NFS_V3_ACL) += nfs3acl.o
 
-obj-$(CONFIG_NFS_V4) += nfs4.o
-nfs4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
+obj-$(CONFIG_NFS_V4) += nfsv4.o
+nfsv4-y := nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o nfs4super.o nfs4file.o \
          delegation.o idmap.o callback.o callback_xdr.o callback_proc.o \
          nfs4namespace.o nfs4getroot.o nfs4client.o
-nfs4-$(CONFIG_SYSCTL)  += nfs4sysctl.o
-nfs4-$(CONFIG_NFS_V4_1)        += pnfs.o pnfs_dev.o
+nfsv4-$(CONFIG_SYSCTL) += nfs4sysctl.o
+nfsv4-$(CONFIG_NFS_V4_1)       += pnfs.o pnfs_dev.o
 
 obj-$(CONFIG_PNFS_FILE_LAYOUT) += nfs_layout_nfsv41_files.o
 nfs_layout_nfsv41_files-y := nfs4filelayout.o nfs4filelayoutdev.o
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9fc0d9d..9969444 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -105,7 +105,7 @@ struct nfs_subversion *get_nfs_version(unsigned int version)
 
        if (IS_ERR(nfs)) {
                mutex_lock(&nfs_version_mutex);
-               request_module("nfs%d", version);
+               request_module("nfsv%d", version);
                nfs = find_nfs_version(version);
                mutex_unlock(&nfs_version_mutex);
        }


> 
> --b.
> 

