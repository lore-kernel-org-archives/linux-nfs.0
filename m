Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:58172 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855Ab2CVATP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Mar 2012 20:19:15 -0400
Message-ID: <4F6A6FB9.7010508@panasas.com>
Date: Wed, 21 Mar 2012 17:18:01 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Greg KH <gregkh@linuxfoundation.org>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>, <keyrings@linux-nfs.org>,
        <linux-security-module@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        NFS list <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "Bhamare, Sachin" <sbhamare@panasas.com>,
        David Howells <dhowells@redhat.com>, Eric Paris <eparis@redhat.com>,
        "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
        Kay Sievers <kay.sievers@vrfy.org>, James Morris <jmorris@namei.org>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Greg Kroah-Hartman <gregkh@suse.de>
Subject: Re: [PATCHSET 0/4] kmod: Optional timeout on the wait in call_usermodehelper_exec
References: <4F691059.30405@panasas.com> <20120321153519.GB30250@kroah.com>
In-Reply-To: <20120321153519.GB30250@kroah.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/21/2012 08:35 AM, Greg KH wrote:
> On Tue, Mar 20, 2012 at 04:18:49PM -0700, Boaz Harrosh wrote:
>> Andrew Hi
>>
>> I'm picking on you because I don't have any one else to pick on.
>> The 3 first patches here, are just good for today. Please see if
>> you would like to take them? or tell me who should take them?
>>
>> The 4th patch is an RFC, which got me looking into this.
>>
>> My motivation is that I added yet another Kernel dependency on the
>> call_usermodehelper() function and am not completely happy with the
>> error case of having the user-mode program stuck forever. In such
>> case I would like the Kernel part to timeout and properly error recover
>> and clean up. So therefor the proposed 4th patch.
> 
> What is this new use of call_usermodhelper that you are doing this work
> for?  Ideally, you never want to make this call, as it's slow and messy,
> as you have found out.  Is there an in-kernel user that you have
> recently added?
> 
> thanks,
> 
> greg k-h

I agree hence my comment in the 4th patch:
	"In the blasphemous occasions that a the Kernel must call a user-mode program"

I have added a new caller, to the nfs/objectlayoutdriver.ko that uses this
facility for auto-login into osd-targets (iscsi-targets) when new are requested
by the filesystem. This auto-login facility is mandated by the pnfs-objects
standard because in a large cluster filesystems for which pnfs was invented, storage
devices break and changed everyday, and a manual login by every client is not
feasible.

You can see this patch as posted to the mailing list here:
	http://article.gmane.org/gmane.linux.nfs/48024/match=login
	[title: pnfs-obj: autologin: Add support for protocol autologin]

It works very well and was heavily tested, with all error scenarios, but
the theoretical possibility that the user-mode program can be stuck forever
bothers me and I would like to do something about it. With this patch the
Kernel can recover cleanly and continue. I have actually tested this part
and it works as expected.

Thanks
Boaz
