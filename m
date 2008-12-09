From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] statd: not unlinking host files
Date: Mon, 08 Dec 2008 19:40:01 -0500
Message-ID: <493DBE61.3020409@RedHat.com>
References: <493A8D71.20603@RedHat.com> <20081208233355.GB24083@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43203 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804AbYLIAmV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 19:42:21 -0500
In-Reply-To: <20081208233355.GB24083@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Sat, Dec 06, 2008 at 09:34:25AM -0500, Steve Dickson wrote:
>> Again working with the state file code, I notice that statd was
>> not unlinking hosts files when the kernel sent up the 
>> sm_unmon messages. This following patch address the reason why... 
>>
>> Comments?
> 
> Bizarre--thanks for catching that.
> 
> But it looks like these are actually the only two callers to xunlink?
> In which case, we should just ditch the "check" parameter entirely and
> avoid some confusion....
I thought of that... I wanted to get the patch out and I wanted
to get some context from the list as to why the check was there... 
I'll clean it up...

steved.

