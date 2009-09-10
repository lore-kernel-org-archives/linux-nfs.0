From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Text based mount options ignoring the preferred rwsize?
Date: Thu, 10 Sep 2009 13:49:32 -0400
Message-ID: <E80C7303-A488-41D1-805C-E84CF5870736@oracle.com>
References: <4AA68AA4.7090606@moving-picture.com>	 <188B198A-A113-4CA7-940D-EFBD026CBDD2@oracle.com>	 <4AA8225A.9060107@moving-picture.com> <1252536970.8722.110.camel@heimdal.trondhjem.org> <4AA8C215.2030002@moving-picture.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: James Pearson <james-p-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:54714 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbZIJRuO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Sep 2009 13:50:14 -0400
In-Reply-To: <4AA8C215.2030002-5Ol4pYTxKWu0ML75eksnrtBPR1lH4CV8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 10, 2009, at 5:08 AM, James Pearson wrote:
> Trond Myklebust wrote:
>> On Wed, 2009-09-09 at 22:47 +0100, James Pearson wrote:
>>> The default behaviour with binary mount options when no [rw]size  
>>> is to select these preferred values - which to me, makes sense -  
>>> as by not giving a [rw]size, you are leaving it up the server to  
>>> pick the 'best' values for you - which I guess in most (all  
>>> other?) cases happen to be the maximum size.
>> Right. The above was indeed the guiding principle back when I did the
>> rsize/wsize negotiation for NFSv3 and NFSv2 for the binary mount  
>> code.
>> The NFS protocol specifies that the maximum values are there to  
>> tell you
>> that the server will do short read/writes if you exceed these.  
>> However,
>> the preferred values may correspond to a different 'sweet spot' for  
>> the
>> server read and write implementations.
>
> So does that mean that the binary mount options are doing the right  
> thing, whereas the text mount options are not? Also, just to  
> confirm, I'm using NFSv3.

I don't think there is a clear right or wrong here.  The binary  
behavior follows protocol guidelines, which is fine.  But, there are  
plenty of cases where using the server's preferred size by default is  
not always optimal.  For example, the server may advertise a  
preference for 32768, but using that setting with UDP on a congested  
network would result in poor performance.

In other words, the client may decide that using a larger or smaller  
setting than the server's preference would be better.  Or, it may use  
the largest possible setting for r/wsize, but advertise the server's  
preference number in stat(2) results.

Fwiw, I don't have any problem switching the text-based defaults to  
zero.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



