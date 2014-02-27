Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:33796 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbaB0Sc6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Feb 2014 13:32:58 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: xfstests with NFS
Date: Thu, 27 Feb 2014 10:32:51 -0800
Message-Id: <27AB99CF-CEF3-4AC5-AFBD-6648F3B3BED2@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph-

I’m running xfstests to validate functionality of a particular NFS client/transport/server set up.

There are a couple of tests that may not always be appropriate for FSTYP=nfs.  We weren’t able to identify a bugzilla where we can report these issues.

generic/192 tests atime changes.  The Linux NFS client (and probably others) typically optimizes away atime changes.  Thus this test fails for NFS mounts on Linux.  I’m wondering if we can treat NFS as always a noatime filesystem.

generic/237 tries setfacl.  On NFS mounts, the operation always returns “Operation not supported,” but the test is looking for “Operation not permitted.”  The former is an acceptable pass, IMO.  I considered disabling this test for NFS, but I would bet some NFS client implementations actually do support setfacl().

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



