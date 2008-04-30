From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Data corruption using 2.6.18 NFSv3 client -- sparse files?
Date: Wed, 30 Apr 2008 00:33:45 -0700
Message-ID: <1209540825.7337.5.camel@heimdal.trondhjem.org>
References: <loom.20080430T061925-652@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Clay McClure <clay-zo/yENU/GurR7s880joybQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:35298 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751232AbYD3Hdu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 03:33:50 -0400
In-Reply-To: <loom.20080430T061925-652-eS7Uydv5nfjZ+VzJOa5vwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-04-30 at 06:41 +0000, Clay McClure wrote:
> Hello,
> 
> When multiple 2.6.18 NFSv3 clients write to the same file, after one of the
> clients has recently read from the file, we see data corruption in the form of
> null bytes inserted into the file.
> 
> Simple test case:
> 
> hosta% echo "line 1" > /nfs/volume/bar.txt 
> 
> then, in rapid succession: 
> 
> hostb% cat bar.txt && sleep 2 && echo "line 2 from hostb" >> /nfs/bar.txt 
> hostc% cat bar.txt && sleep 2 && echo "line 2 from hostc" >> /nfs/bar.txt 
> 
> Expected result:
> 
> /nfs/bar.txt contains:
> 
> line 1
> line 2 from hostb
> line 2 from hostc
> 
> Actual result:
> 
> /nfs/bar.txt contains:
> 
> line 1
> \0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0line 2 from hostc
> 
> This seems to be due to an inconsistency between the page cache and the
> attribute cache on hostc. Running the 'cat' command on hostc causes bar.txt
> to be loaded into the page cache. Meanwhile, its attributes are cached in the
> attribute cache.
> 
> Seconds later, the 'echo' command on hostc causes the attribute cache to be
> updated (a GETATTR operation is issued) with the new file size (reflecting
> the line just appended by hostb), but the page cache is not updated (no READ
> operation is issued).
> 
> The subsequent WRITE operation from hostc specifies an offset of 0 (beginning
> of file) and a length equal to "line 1" + "line 2 from hostb" + "line 2 from 
> hostc". Since the page cache on hostc does not contain the "line 2 from hostb"
> content, that segment of the WRITE buffer is filled with nulls.
> 
> Note that no file locking is being used in this test case or our production
> use case.
> 
> Questions:
> 
> - Is this a bug or correct operation?
> - Would file locking produce the expected behaviour?
> 
> Thanks,
> 
> Clay McClure


A number of read and write races have been fixed since September 2006.
Have you tested with 2.6.25?

Trond

