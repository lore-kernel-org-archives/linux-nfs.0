From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 30 Jun 2008 12:00:05 -0400
Message-ID: <48690305.20401@oracle.com>
References: <48652C24.6030409@gmail.com> <OF20F6A497.A6F52D0F-ON65257478.00377AB6-65257478.0037E4AE@in.ibm.com> <20080630112654.012ce3e4@barsoom.rdu.redhat.com> <20080630153541.GD29011@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070506000905040904000205"
Cc: Jeff Layton <jlayton@redhat.com>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Dean Hildebrand <seattleplus@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>, aglo@citi.umich.edu
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:50602 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbYF3QCL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 12:02:11 -0400
In-Reply-To: <20080630153541.GD29011@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070506000905040904000205
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Mon, Jun 30, 2008 at 11:26:54AM -0400, Jeff Layton wrote:
>> Recently I spent some time with others here at Red Hat looking
>> at problems with nfs server performance. One thing we found was that
>> there are some problems with multiple nfsd's. It seems like the I/O
>> scheduling or something is fooled by the fact that sequential write
>> calls are often handled by different nfsd's. This can negatively
>> impact performance (I don't think we've tracked this down completely
>> yet, however).
> 
> Yes, we've been trying to see how close to full network speed we can get
> over a 10 gig network and have run into situations where increasing the
> number of threads (without changing anything else) seems to decrease
> performance of a simple sequential write.
> 
> And the hypothesis that the problem was randomized IO scheduling was the
> first thing that came to mind.  But I'm not sure what the easiest way
> would be to really prove that that was the problem.

Here's an easy way for reads:  instrument the VFS code that manages 
read-ahead contexts.  Probably not an issue for krkumar2, since the file 
from one of the read tests is small enough to fit in the server's cache, 
and the other read test involves only /dev/null.

I had always thought wdelay would mitigate write request re-ordering, 
but I've never looked at how it's implemented in Linux's nfsd.  Of 
course, if the client is sending too many COMMIT requests, this will 
negate the benefit of wdelay.

--------------070506000905040904000205
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck_lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck_lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------070506000905040904000205--
