From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: merging sm-notify and rpc.statd
Date: Tue, 19 May 2009 18:10:50 -0700
Message-ID: <4A13589A.6050406@candelatech.com>
References: <E9DE1ACD-4C9D-43F8-9B00-28CE536BFDBD@oracle.com>    <18963.13619.563465.804193@notabene.brown>    <200905191925.38902.vapier@gentoo.org> <bdacaae74fbd57ee96599286eae43751.squirrel@neil.brown.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Mike Frysinger <vapier@gentoo.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57046 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755287AbZETBLE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 May 2009 21:11:04 -0400
In-Reply-To: <bdacaae74fbd57ee96599286eae43751.squirrel-eq65iwfR9nKIECXXMXunQA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:
> They really are separate functions.
>   
Maybe have one code base and have it do different things based on a cmd-line
argument or the name (use a symlink for one of the functions) ?

If the code is really similar, that should allow easy reuse?

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


