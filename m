From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: Huge race in lockd for async lock requests?
Date: Fri, 29 May 2009 09:22:53 -0400
Message-ID: <4a1fe1c0.06045a0a.165b.5fbc@mx.google.com>
References: <4A0D80B6.4070101@redhat.com>
 <4A0D9D63.1090102@hp.com>
 <4A11657B.4070002@redhat.com>
 <4A1168E0.3090409@hp.com>
 <4A1319F9.90304@hp.com>
 <4A13A973.4050703@hp.com>
 <4a140d0a.85c2f10a.53bc.0979@mx.google.com>
 <4A1431B1.6080708@hp.com>
 <20090528200523.GE13860@fieldses.org>
 <4A1F035B.4040306@hp.com>
 <20090529002636.GA19184@fieldses.org>
 <4A1F4F76.70108@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Rob Gardner <rob.gardner@hp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.30]:61644 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753991AbZE2NXN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 09:23:13 -0400
Received: by yx-out-2324.google.com with SMTP id 3so3330550yxj.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 May 2009 06:23:14 -0700 (PDT)
In-Reply-To: <4A1F4F76.70108@hp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 10:59 PM 5/28/2009, Rob Gardner wrote:
>J. Bruce Fields wrote:
>>
>> Looking at the code....  This is all under the BKL, and as far as I can
>> tell there aren't any blocking operations anywhere there, so I don't
>> think this should happen if the filesystem is careful.  Have you seen it
>> happen?
>
>
>Aha, I just figured it out and you were right. The filesystem in this 
>case was not careful. It broke the rules and actually made the fl_grant 
>call *before* even returning to nlmsvc_lock's call to vfs_lock_file, and 
>it did it in the lockd thread! So the BKL was of no use, and I saw 
>nlmsvc_grant_deferred print "grant for unknown block". So I think 
>everything is ok, no huge race in lockd for async lock requests. Thank 
>you for clearing this up.

Gack! I'm surprised it worked at all. The fact that the BKL allows itself to
be taken recursively really masked your filesystem bug. If the BKL had
blocked, or asserted, the bug would never have happened.

This is as good a time as any to point out that the BKL's use in the lockd
code is insidious and needs some serious attention. Unfortunately, it's also
wrapped up in the BKL use of the VFS locking layer, but in practice those
are two different things. Using the BKL for upcall/downcall synchronization
and lockd thread protection are the issue here.

Tom.

