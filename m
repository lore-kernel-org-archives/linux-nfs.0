Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:34607 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756596Ab0JANoq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 09:44:46 -0400
Received: by qyk36 with SMTP id 36so3337845qyk.19
        for <linux-nfs@vger.kernel.org>; Fri, 01 Oct 2010 06:44:45 -0700 (PDT)
Message-ID: <4CA5E5CB.7000204@stevek.com>
Date: Fri, 01 Oct 2010 09:44:43 -0400
From: Steve Kann <stevek@stevek.com>
To: linux-nfs@vger.kernel.org
Subject: question about serialization/queuing behavior in linux nfs client
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hi, List,

     I'm trying to debug some performance problems I've been seeing in a 
particular application.  My main problem is the simple case of an 
overloaded server, but there's one aspect of the behavior I'm seeing in 
benchmarks that I don't quite understand.

Basics:
     I'm doing benchmarks from a CentOS4 (2.6.9-78.0.13), using NFSv3 
(over tcp) to connect to a NetApp filer.
     My benchmark application is a simple perl script which times 
directory operations (stat, mkdir, rmdir), and I typically am running 
between 20-200 parallel copies.

What I don't quite understand is that if I look on the wire, I see the 
"worst case" operation times taking up to about ~10 seconds, but from 
the application, it's reporting worst case times in the 30-60 (or 
higher!) second range.

At first, I thought that perhaps the system calls in the application 
were being mapped into multiple NFS operations, but that does not appear 
to be the case.

My second thought was that the kernel is somehow limiting the number of 
outstanding requests it's issuing to the server.  It seems that way back 
in kernel 2.4, there was a limit of 256 outstanding requests (as per 
nfs.sourceforge.net FAQ B7), but that hard limit was removed back in 2.5 
with this patch from Trond (http://lwn.net/Articles/15074/), and 
replaced with other mechanisms to limit memory usage.

The machine I'm testing from has 4GB, and a pretty low application 
memory footprint (there's nothing much else running on the machine other 
than my tests).

Any idea what causes the disparity between what I'm seeing on the wire, 
and what my test application is seeing?

Thanks for helping me understand,

-SteveK

