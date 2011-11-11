Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:38606 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756025Ab1KKMwk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Nov 2011 07:52:40 -0500
Date: Fri, 11 Nov 2011 07:52:30 -0500
From: Jim Rees <rees@umich.edu>
To: Andrew Cooper <andrew.cooper3@citrix.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: unexpected NFS timeouts, related to sync/async soft mounts over
 TCP
Message-ID: <20111111125230.GA14491@umich.edu>
References: <4EBAC88D.40902@citrix.com>
 <BEF32B02-0D19-4D97-8E93-C1797DF02CFE@oracle.com>
 <4EBBB247.40805@citrix.com>
 <2E3D3F87-479E-4096-B086-C8F83A0147B5@oracle.com>
 <4EBBF35B.5000606@citrix.com>
 <1320957784.11956.16.camel@lade.trondhjem.org>
 <4EBCF98E.6050101@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EBCF98E.6050101@citrix.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Cooper wrote:

  As for TCP timestamps; I have a Timestamp option in each TCP packet. 
  Nothing appears corrupted.  What would I be looking for with corrupted
  timestamps?

I had a faulty NAT once that was changing the ts ecr in the syn ack packet,
causing the other end to send rst.  I can't remember if wireshark flagged
this as bad or I found it manually.  I do remember that there was no log
message from the linux kernel.  I'll bet there's some tool that will read a
pcap and verify the timestamps.
