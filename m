From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs + Reiser4
Date: Wed, 07 Apr 2010 14:44:01 -0400
Message-ID: <4BBCD271.5040100@oracle.com>
References: <op.vaq49joctxpshh@localhost.localdomain>
	<20100407173438.GA25614@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:49323 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755678Ab0DGSpg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 14:45:36 -0400
Received: from brown by neil.brown.name with local (Exim 4.71)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NzaFq-0001fc-E8
	for linux-nfs@vger.kernel.org; Thu, 08 Apr 2010 04:45:34 +1000
In-Reply-To: <20100407173438.GA25614@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/07/2010 01:34 PM, J. Bruce Fields wrote:
> On Tue, Apr 06, 2010 at 07:52:21PM +0200, gg-B3jsHfKwJfLR7s880joybQ@public.gmane.org wrote:
>> I am having serious headaches using nfs between a reiser4 server and arm
>> client.
>> Both on 2.6.29 vintage kernels.
>>
>> Files are constantly getting out of sync.
>>
>> Example :
>>
>> boot ARM via nfs
>> edit lighttpd.conf on ARM
>> check edit is visible on server. OK
>>
>> reboot ARM
>> check file : reverted to an earlier state.
>> check server: edited version still showing.
>
> So, on a freshly booted NFS client, you're opening and reading a file
> and seeing file data that isn't even on the NFS server any more?
>
> That's beyond bizarre.  Do you have a reliable way to reproduce the
> problem?

Could be XID replay.

-- 
chuck[dot]lever[at]oracle[dot]com

------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

