Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:61462 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933106AbZHDRgQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Aug 2009 13:36:16 -0400
Subject: NFS/IPv6
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
        "Dr. J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain
Date: Tue, 04 Aug 2009 13:35:24 -0400
Message-Id: <1249407324.5041.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi guys,

There was apparently a presentation and proposal made at the IETF in
Stockholm w.r.t. standardising IPv6 support in lockd/statd, and adding
link-local addresses to NFSv4. The proposal could possibly have
consequences for our implementation efforts.

Please see the slides and minutes here

http://www.ietf.org/proceedings/75/minutes/nfsv4.txt

  and

http://www.ietf.org/proceedings/75/slides/nfsv4-0.pdf

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
