Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e34.co.us.ibm.com ([32.97.110.152]:44620 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752466Ab3CTWkQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Mar 2013 18:40:16 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <cvogan@us.ibm.com>;
	Wed, 20 Mar 2013 16:40:15 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 5ADE03E4004E
	for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2013 16:40:02 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2KMeDXD166084
	for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2013 16:40:13 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2KMeC2s010409
	for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2013 16:40:13 -0600
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com [9.63.40.222])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r2KMeC5H010406
	for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2013 16:40:12 -0600
To: linux-nfs@vger.kernel.org
MIME-Version: 1.0
Subject: Re: What is NFSv4 READDIR doesn't return a filehandle....
Message-ID: <OF5A466E86.6A319FE3-ON87257B34.007C6188-86257B34.007C87C8@us.ibm.com>
From: Christopher T Vogan <cvogan@us.ibm.com>
Date: Wed, 20 Mar 2013 17:40:11 -0500
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All,

Sorry for this late posting, a coworker was made aware of this thread 
recently and
has these replies to make.  Our server implementation is the one being
complained about in this thread.


Quoted text is from various entries in this forum.


Neil Brown:
===========
> Just a thought: while coping with broken servers would not be a good 
path to
> follow, detecting protocol violations and reporting an error might be...
> should the NFS client treat a missing filehandle and a malformed reply?

The server is allowed to remove an attribute bit from an entry in the 
readdir
reply, this is not "broken" nor is the reply "malformed".  The lack of a 
filehandle in the reply is deterministic.



Trond Myklebust:
================
> > A customer has come across a server which does not return the 
filehandle
> > information (is that allowed?).
> 
> The filehandle attribute is a mandatory attribute according to RFC3530, 
so I believe that the answer is "no".

Mandatory is described in RFS 3530 as that the server must return the 
attribute
on a GETATTR.  (Section 5, page 36).  There is nothing saying that it is
mandatory to return on a READDIR.  Our server will return the filehandle
on a LOOKUP/GETATTR every time.


Trond Myklebust:
================
> My concern is that the client can't objectively judge what constitutes a
> valid filehandle and what does not until it tries to use it in an RPC
> call.

Sure it can.  In the context of this discussion, if the readdir entry
has the filehandle attribute bit off in the reply, there is no filehandle.

I would note in the scenario we sent a trace for, the Linux client had 
a filehandle for the node in question, and "misplaced" it after a 
readdir to the directory containing that node did not return the 
filehandle
for that entry.  So calling the server "broken" is objectively inaccurate.

I would also note that this problem occurred after we upgraded to RHEL 
6.3;
the prior version did not have this issue, and our server did not change 
its
behavior.  My conclusion is that the means to obtain the filehandle was 
either broken by the client adding logic to assume a filehandle and 
obliterate 
the prior value after a readdir reply chose not to return it, or 
previously 
had a code path to lookup the node and obtain the filehandle, and removed 
that code path for some reason.  So again, pointing to server "breakage" 
is objectively inaccurate.

There are many references to "brokenness" or "server bugs" in this 
thread, and I take exception to it from a design and protocol conformance 
point of view.

This condition is easily recoverable, as ANY missing attribute on a 
readdir
is with a lookup/readdir.  Our decision to not return the FH on a readdir 
reply under certain narrow conditions is not one of convenience but of 
limitations of some underlying filesystem types, and if "convenience" is
to be used as an accusative, it can easily be returned to the client's 
refusal to deal with the legal withholding of an attribute on a readdir
reply.


Signed,
Steve Huntington
IBM z/OS NFS


Christopher Vogan
Dept. W98 NFS Development & Test

