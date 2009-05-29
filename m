From: Rob Gardner <rob.gardner@hp.com>
Subject: Re: Huge race in lockd for async lock requests?
Date: Fri, 29 May 2009 09:24:25 -0600
Message-ID: <4A1FFE29.2060306@hp.com>
References: <4A0D80B6.4070101@redhat.com> <4A0D9D63.1090102@hp.com> <4A11657B.4070002@redhat.com> <4A1168E0.3090409@hp.com> <4A1319F9.90304@hp.com> <4A13A973.4050703@hp.com> <4a140d0a.85c2f10a.53bc.0979@mx.google.com> <4A1431B1.6080708@hp.com> <20090528200523.GE13860@fieldses.org> <4A1F035B.4040306@hp.com> <20090529002636.GA19184@fieldses.org> <4A1F4F76.70108@hp.com> <4a1fe1c0.06045a0a.165b.5fbc@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Tom Talpey <tmtalpey@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:13831 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757824AbZE2PYY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 May 2009 11:24:24 -0400
In-Reply-To: <4a1fe1c0.06045a0a.165b.5fbc-ATjtLOhZ0NVl57MIdRCFDg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Tom Talpey wrote:
> At 10:59 PM 5/28/2009, Rob Gardner wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> Looking at the code....  This is all under the BKL, and as far as I can
>>> tell there aren't any blocking operations anywhere there, so I don't
>>> think this should happen if the filesystem is careful.  Have you seen it
>>> happen?
>>>       
>> Aha, I just figured it out and you were right. The filesystem in this 
>> case was not careful. It broke the rules and actually made the fl_grant 
>> call *before* even returning to nlmsvc_lock's call to vfs_lock_file, and 
>> it did it in the lockd thread! So the BKL was of no use, and I saw 
>> nlmsvc_grant_deferred print "grant for unknown block". So I think 
>> everything is ok, no huge race in lockd for async lock requests. Thank 
>> you for clearing this up.
>>     
>
> Gack! I'm surprised it worked at all. The fact that the BKL allows itself to
> be taken recursively really masked your filesystem bug. If the BKL had
> blocked, or asserted, the bug would never have happened.
>   

Yeah, recall that I'm using a very old kernel (circa 2.6.18) which I 
think must still allow the BKL to be acquired recursively.

> This is as good a time as any to point out that the BKL's use in the lockd
> code is insidious and needs some serious attention. 
No disagreement here! I think I almost understand enough about lockd to 
remove the BKL, but the operative word there is "almost".


Rob Gardner


