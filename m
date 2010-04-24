Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:20639 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940Ab0DXIpw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Apr 2010 04:45:52 -0400
From: "Bathie, Jon" <jon.bathie@hp.com>
To: Steve Dickson <SteveD@redhat.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sat, 24 Apr 2010 08:40:51 +0000
Subject: RE: NFS client send out of order offsets....
Message-ID: <73426775AB69B147AD552C78C2401B377A6F7405B0@GVW1088EXB.americas.hpqcorp.net>
References: <4BD21777.1060305@RedHat.com>
In-Reply-To: <4BD21777.1060305@RedHat.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve,

Further investigation sonce we spoke has shown that our intial Solaris data point may have been spurious.

However, we still think that both Solaris and HP-UX have options to force "ordering" of data between client and server.

Jon.

-----Original Message-----
From: Steve Dickson [mailto:SteveD@redhat.com] 
Sent: 23 April 2010 22:56
To: Linux NFS Mailing list; Trond Myklebust
Subject: NFS client send out of order offsets....

Hey Trond (and all),

It been brought to my attention that Linux NFS clients, with big-ish writes (8GB and above), quickly started sending out writes with out-of-order offsets... Meaning in the start of an 8GB write a 7GB offset will be send and then smaller offsets, closer to the the beginning of the file, will follow.

Now I realize this is perfectly fine from a protocol standpoint and (w/out any on hands investigation) pretty sure it has to do with how pages are being kicked out of the cache (i.e. memory pressure), meaning is not an NFS issue at all...  but... 

It was also point out to me that this type of out of order-ness does not happen with Solaris clients and with an AIX clients there is some mount option fix out of order-ness... 

So my question is there some way to tweak the client to ensure offset are send sequential order... 

Note this happening on a older kernel, so before I go off  and "re-invent the wheel", I was wonder if other people have seen this issue and has it been addressed... 

tia,

steved.
