Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38194 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757425Ab0DWV5Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Apr 2010 17:57:16 -0400
Message-ID: <4BD21777.1060305@RedHat.com>
Date: Fri, 23 Apr 2010 17:56:07 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: NFS client send out of order offsets....
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Trond (and all),

It been brought to my attention that Linux NFS clients, with big-ish 
writes (8GB and above), quickly started sending out writes with
out-of-order offsets... Meaning in the start of an 8GB write a 7GB offset 
will be send and then smaller offsets, closer to the the beginning 
of the file, will follow.

Now I realize this is perfectly fine from a protocol standpoint and (w/out 
any on hands investigation) pretty sure it has to do with how pages are
being kicked out of the cache (i.e. memory pressure), meaning is 
not an NFS issue at all...  but... 

It was also point out to me that this type of out of order-ness does 
not happen with Solaris clients and with an AIX clients there is some 
mount option fix out of order-ness... 

So my question is there some way to tweak the client to ensure
offset are send sequential order... 

Note this happening on a older kernel, so before I go off  and 
"re-invent the wheel", I was wonder if other people have seen this
issue and has it been addressed... 

tia,

steved.
