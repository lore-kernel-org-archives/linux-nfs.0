From: Steve Dickson <SteveD@redhat.com>
Subject: nfsd module refcount is out of control....
Date: Wed, 30 Jan 2008 09:23:31 -0500
Message-ID: <47A08863.40400@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40006 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757600AbYA3OYy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Jan 2008 09:24:54 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m0UEOreJ022341
	for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2008 09:24:53 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m0UEOqIM029616
	for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2008 09:24:52 -0500
Received: from [10.13.248.46] (vpn-248-46.boston.redhat.com [10.13.248.46])
	by lacrosse.corp.redhat.com (8.12.11.20060308/8.11.6) with ESMTP id m0UEOph0010462
	for <linux-nfs@vger.kernel.org>; Wed, 30 Jan 2008 09:24:52 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Has anybody noticed that bring up kNFSD (using a 2.6.24 kernel)
causes 17 modules references on nfsd?

# lsmod | grep nfsd
nfsd                  201584  17 
lockd                  60488  2 nfsd
nfs_acl                 6656  1 nfsd
auth_rpcgss            39360  1 nfsd
exportfs                7936  1 nfsd
sunrpc                157892  10 nfsd,lockd,nfs_acl,auth_rpcgss

It appears one of the culprits is svc_set_num_threads() since
it does a module_get() for every thread, which seems a bit
excessive imho...  What happen to the idea of the first thread 
creating the refcount and the last thread removing the 
refcount?

Anyways, I don't see any routine removing all those 
refcounts. Should something like svc_exit_thread() be
doing the module_put() since svc_set_num_threads did
all those gets? If not, how are all those refcounts
suppose to be removed?  

Also, does anybody have clue as to why auth_rpcgss is 
being insmod-ed when there are no secure exports 
defined?

tia,

steved.

