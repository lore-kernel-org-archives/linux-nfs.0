From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfsstat --sleep=#
Date: Thu, 12 Mar 2009 16:24:56 -0400
Message-ID: <D5529973-DEFB-4D86-BB94-38EC03517B95@oracle.com>
References: <49B86744.6060105@disney.com> <ADDF97BC-8B6A-4EFC-9242-C1454B8F423C@oracle.com> <20090312155055.GB2081@fieldses.org> <65B488F7-A902-4126-8E05-65622991D78C@oracle.com> <20090312162459.GC2081@fieldses.org> <49B93C10.5020208@disney.com> <20090312164818.GF2081@fieldses.org> <82886FA0-DF61-4979-B914-3CC59BAA2493@oracle.com> <20090312193210.GA7530@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>,
	Steve Dickson <SteveD@redhat.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:53701 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751012AbZCLUZ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 16:25:29 -0400
In-Reply-To: <20090312193210.GA7530@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 12, 2009, at Mar 12, 2009, 3:32 PM, J. Bruce Fields wrote:
> On Thu, Mar 12, 2009 at 01:22:32PM -0400, Chuck Lever wrote:
>> Actually I would rather see the performance metrics scripts improved.
>> These tools give a lot more information than nfsstat ever will be  
>> able
>> to.
>
> Probably so, but those scripts are a bit hard to find, aren't they?
>
> We should
> 	- get distributions to install them by default
> 	- write man pages?
> 	- add references to them where possible (from the nfsstat man
> 	  page, from howto's/faq's/?)

Steve promised me Red Hat would take care of this when these were  
added to nfs-utils last year.

> Until then, unfortunately, improvements to nfsstat are more useful,
> since nfsstat is the thing people are more likely to run across.

Again, I think improving nfsstat at this point (which is merely for  
compatibility with Solaris) would be wasted work, if we already have  
what is needed in another tool.  The Python tools are much more  
sophisticated, and it would be confusing to add their functionality to  
nfsstat (e.g. why can I zero the legacy stats with the -z option, but  
not the stats the come from /proc/self/mountstats?).

Let's spend the effort on the tools that give us deeper results.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
