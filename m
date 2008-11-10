From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] export dir thru 2 diff path names
Date: Mon, 10 Nov 2008 15:44:43 -0500
Message-ID: <20081110204443.GK19053@fieldses.org>
References: <491869F0.1000505@bnl.gov>
	<620E93B2E5CC3B46BD811165E3335B8702F374A0@0461-its-exmb02.us.saic.com>
	<491882AB.6070908@bnl.gov>
	<620E93B2E5CC3B46BD811165E3335B8702F37542@0461-its-exmb02.us.saic.com>
	<4918859C.6080608@bnl.gov>
	<620E93B2E5CC3B46BD811165E3335B8702F3759D@0461-its-exmb02.us.saic.com>
	<20081110192820.GC19053@fieldses.org>
	<ED53D02C-E3A1-4989-904C-CBCB4CCD29EE@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>,
	nfs@lists.sourceforge.net, Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45894 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026AbYKJUp3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 15:45:29 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KzddW-0000FG-TG
	for linux-nfs@vger.kernel.org; Tue, 11 Nov 2008 07:45:26 +1100
In-Reply-To: <ED53D02C-E3A1-4989-904C-CBCB4CCD29EE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 10, 2008 at 03:20:42PM -0500, Chuck Lever wrote:
> On Nov 10, 2008, at Nov 10, 2008, 2:28 PM, J. Bruce Fields wrote:
>> On Mon, Nov 10, 2008 at 11:28:04AM -0800, Murata, Dennis wrote:
>>> That really is the 64K question.  During my initial testing, I  
>>> exported
>>> the parent directory.  Now I am explicitly exporting the installation
>>> directories, where I see the exportfs message.  In the messages log  
>>> file
>>> on the server the mount request from the client is always the actual
>>> directory.
>>
>> I don't see how this would be "unsafe"--if it works, go for it.
>>
>> One potential trap: it's using the same client list and export options
>> for both, so if you think you can make one of them read-only and one  
>> of
>> them writeable, for example, you'll be disapointed.
>
> I wonder how this behaves on the client side.  If the same client mounts 
> both paths, will it recognize that these are the same and use a shared 
> page cache for both?

Yeah, who knows.  I suspect it assumes they're different if the mount
paths are different.

But for most people's purposes it probably doesn't matter much.  (For
the purposes people have mentioned so far they don't even need to mount
both paths from the same client at once.)

--b.

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

