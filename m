Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:30809 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754273Ab2J2BDy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Oct 2012 21:03:54 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: Legacy NFS client DNS resolver fails since 2.6.37
Date: Sun, 28 Oct 2012 21:03:45 -0400
Message-Id: <6F448C67-E729-41E7-A09C-A49D15B50D5E@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

To use the legacy DNS resolver for resolving hostnames in NFSv4 referrals, I've installed the /sbin/nfs_cache_getent script on my NFS client "degas."  I've confirmed it works with a 2.6.36 kernel.

However, since 2.6.37 commit c5b29f885afe890f953f7f23424045cdad31d3e4 "sunrpc: use seconds since boot in expiry cache" the legacy DNS resolver appears not to work.  When attempting to follow a referral that uses a server hostname, the client fails 100% of the time to mount the referred to server with an error such as:

  [cel@degas example.net]$ ls home
  ls: cannot open directory home: No such file or directory

The contents of the dns_resolve cache appear to indicate that there are resolution results in the cache, but the CACHE_VALID flag is not set for that entry:

  [root@degas dns_resolve]# cat content 
  # ip address      hostname        ttl
  #               , klimt.example.net 48

klimt.example.net is the hostname that is contained in the referral.

I have a second referral called "ip-address" in the same directory (domainroot), with the same content except the IP address of klimt is used instead of its hostname.  Following that second referral always works.

I've tried every stable.0 release up to 3.6.0, and the behavior is roughly the same for each, which suggests that there is no upstream fix for this issue thus far.

Since I've never seen a problem like this reported, I'm wondering if anyone else can confirm this issue.

I have a narrow interest in fixing the legacy DNS server in stable kernels, but there may also be a latent problem with the RPC cache implementation that could spell trouble for other consumers, even post-3.6.

A rough outline of how you might reproduce this:

  + Build and install a 2.6.37 or later kernel for your NFS client with CONFIG_NFS_USE_LEGACY_DNS=y.

  + Set up an NFS server with "refer=" exports.  man exports(5)

  + On your client, mount the server directory that contains the exports, then try to "cd" through one of the referrals.

If you don't feel up to replicating the above arrangement, can you suggest cache debugging instrumentation that can be added to my client to help nail this?  Thanks for any advice!

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




