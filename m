Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:46923 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755011Ab3DVUkO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Apr 2013 16:40:14 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: Interoperable junctions on Linux
Message-Id: <71999CA2-F6E7-4DE1-9DC3-AED77626DE7F@oracle.com>
Date: Mon, 22 Apr 2013 16:39:45 -0400
To: samba-technical@lists.samba.org,
        fedfs-utils Developers <fedfs-utils-devel@oss.oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I led a discussion on Friday at the Linux Storage and Filesystem Summit on how to store {DFS, FedFS} junctions in Linux filesystems.  I'd like to summarize the discussion, then ask a few follow-up questions.  I apologize in advance for the length.

FedFS is to NFS as Microsoft DFS is to SMB/CIFS.  FedFS uses NFS referrals to glue together a file namespace out of separate shares, starting with a root share that may contain nothing but referrals.  For more on FedFS, start with RFC 5716.

The physical object that stores referral location target information is called a junction.  It can contain an actual list of locations, or it can contain the DN of an LDAP record where the location list is maintained.

 +  Samba uses a symlink for this purpose.  The contents of the link represent the location information passed out to CIFS clients.

 +  FedFS uses an extended attribute on a directory for this purpose.  The xattr contains XML which encodes location information passed out to NFS clients.

The reasons for this difference are simply historical.

Linux is often used as a multi-protocol file service platform, where the same physical data is presented to clients via both NFS and CIFS.  For this reason, we think there would be value in using the same physical representation for both NFSD and Samba so that a single junction object on our exported filesystems can trigger a referral for both NFS and CIFS.

Samba has been around much longer, and DFS support is actually deployed.  FedFS is newer and still experimental.  Thus we decided to change FedFS to use a symlink instead of a directory.  Samba will still use the regular contents of the symlink, and FedFS will store its metadata in an extended attribute attached to the symlink.

There was a rough consensus to prefer JSON over XML in the FedFS xattr, though there are still some who dislike both.  I'm open to suggestion, since we're now essentially replacing the existing FedFS junction format and can change it to anything we like.

Today FedFS junctions can contain either a location list or an LDAP DN.  One option for FedFS is to support only the LDAP DN junction type, and have a (possibly local) LDAP service available to store the location information.  The FedFS junction xattr would then always contain an LDAP URL.  Storing complex data types (a list containing pathnames, hostnames, integers, and other values) would then be up to LDAP.

We will have to discuss a conjunction of administrative interfaces at some later point.  However, we should clarify how our junction management tools behave now that each junction can have metadata it did not have before.

FedFS:

  nfsref add - if no symlink exists, create it (what contents should it have?)
             - add an extended attribute

  nfsref remove - remove the extended attribute, leave the symlink
                - can we remove the symlink if its contents are meaningless?


Samba:

  add - if a symlink already exists, replace its contents, preserving xattrs

  remove - if a FedFS extended attribute exists, leave the symlink (what contents should it have?)


The FedFS extended attribute is called "trusted.junction.nfs".  Should we rename it?

Note that CAP_SYS_ADMIN capabilities are required to access the xattr.  Will that be a problem for Samba administration tools?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




