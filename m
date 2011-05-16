Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:22383 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751857Ab1EPTku convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 15:40:50 -0400
Received: from rtcsinet22.oracle.com (rtcsinet22.oracle.com [66.248.204.30])
	by rcsinet10.oracle.com (Switch-3.4.2/Switch-3.4.2) with ESMTP id p4GJemYn023570
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 16 May 2011 19:40:50 GMT
Received: from acsmt358.oracle.com (acsmt358.oracle.com [141.146.40.158])
	by rtcsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id p4GJelSJ022033
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 16 May 2011 19:40:48 GMT
Received: from abhmt007.oracle.com (abhmt007.oracle.com [141.146.116.16])
	by acsmt358.oracle.com (8.12.11.20060308/8.12.11) with ESMTP id p4GJegED004741
	for <linux-nfs@vger.kernel.org>; Mon, 16 May 2011 14:40:42 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: SEQ4_STATUS_ question
Date: Mon, 16 May 2011 15:40:40 -0400
Message-Id: <FB972601-FDA2-4C1D-B695-5D268CD568C1@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi-

In minor version 1, the "lease moved" condition is indicated via a flag set in the result of a SEQUENCE operation; in mv0, it was a real NFS4ERR status code.

I don't see anything in RFC 5661 that says SEQUENCE returns anything but NFS4_OK if one or more of these flags are set.  But nfs41_sequence_call_done checks these status flags only when task->tk_status < 0.

If SEQUENCE returns a non-NFS4_OK status code when these flags are set, and MUST be the first operation in a compound, how can anything else in any compound with a SEQUENCE operation get done?

To clear a "lease moved" condition requires that the client send an operation that will get an NFS4ERR_MOVED result.  I assume such a compound would require an initial SEQUENCE operation... but that should fail, since there is a "lease moved" condition.

What am I missing?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




