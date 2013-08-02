Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:41442 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754401Ab3HBQPT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Aug 2013 12:15:19 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so843219pad.9
        for <linux-nfs@vger.kernel.org>; Fri, 02 Aug 2013 09:15:18 -0700 (PDT)
Received: from [128.95.176.96] (moist.atmos.washington.edu. [128.95.176.96])
        by mx.google.com with ESMTPSA id a5sm11133271pbw.4.2013.08.02.09.15.17
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 Aug 2013 09:15:17 -0700 (PDT)
Message-ID: <51FBDB14.4040801@uw.edu>
Date: Fri, 02 Aug 2013 09:15:16 -0700
From: Harry Edmon <harry@uw.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: clientid is in use
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Occasionally I am seeing the following in our kernel log on a NFS client:

[2321389.137595] NFS: Server enkf reports our clientid is in use
[2321389.137615] NFS: state manager: lease expired failed on NFSv4 server enkf 
with error 1

The result is that the read of the file in question fails.   This occurs for 
multiple kernel versions on multiple machines.  Anyone have an idea how I should 
start debugging this?  How is the clientid calculated/assigned?
-- 
Dr. Harry Edmon
harry@uw.edu, 206-543-0547, FAX: 206-543-0308
Director of IT, College of the Environment and
Director of Computing, Dept of Atmospheric Sciences
University of Washington, Box 351640, Seattle, WA 98195-1640
