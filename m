From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock
 restart
Date: Sat, 19 Dec 2009 11:42:16 -0500
Message-ID: <4B2D0268.2080501@RedHat.com>
References: <4B275EA3.9030603@cn.fujitsu.com> <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com> <4B28B5FD.5000103@cn.fujitsu.com> <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com> <4B2A02C6.6080501@cn.fujitsu.com> <35D45F43-D98F-460E-8060-F7C5F3ADFCFE@oracle.com> <20091218101438.48eb06a4@notabene.brown> <E8858040-69E2-4F09-A369-92713BF57161@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>,
	"Trond.Myklebust Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63151 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752886AbZLSQmh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Dec 2009 11:42:37 -0500
In-Reply-To: <E8858040-69E2-4F09-A369-92713BF57161@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/18/2009 10:18 AM, Chuck Lever wrote:
> 
> On Dec 17, 2009, at 6:14 PM, Neil Brown wrote:
> 
>> On Thu, 17 Dec 2009 11:18:53 -0500
>> Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>> Jeff Layton pointed out to me yesterday that Red Hat's nfslock script
>>> unconditionally deletes sm-notify's pid file every time "service
>>> nfslock start" is done, which effectively defeats sm-notify's reboot
>>> detection.
>>>
>>> sm-notify was written by a developer at SuSE.  SuSE Linux uses a tmpfs
>>> for /var/run, but Red Hat uses permanent storage for this directory.
>>> Thus on SuSE, the pid file gets deleted automatically by a reboot, but
>>> on Red Hat, the pid file must be deleted "by hand" or reboot
>>> notification never occurs.
>>
>> Just to make sure the facts are straight:
>> SuSE does not use tmpfs for /var/run (much as I personally think that
>> would be a very sensible approach for both /var/run and /var/locks).
>> It appears that Debian can use tmpfs for these, but doesn't by default.
>>
>> Both SuSE and Debian have boot time scripts that clean up /var/run and
>> other
>> directories.  They remove all non-directories other than /var/run/utmp.
>>
>> If Redhat doesn't clean up /var/run at boot time, then I would think
>> that is
>> very odd.  The files in there represent something that is running.  At
>> boot,
>> nothing is running, so it should all be cleaned up.  Are you sure Redhat
>> doesn't clean out /var/run???
>>
>> I just had a look at master.kernel.org (the only fedora machine I can
>> think
>> of that I have access to) and in /etc/rc.d/rc.sysinit I find
>>
>>    find /var/lock /var/run ! -type d -exec rm -f {} \;
>>
>> So I'm thinking that if you just remove
>>
>>        # Make sure locks are recovered
>>        rm -f /var/run/sm-notify.pid
>>
>> from /etc/init.d/nfslock, then it will do the right thing.
> 
> Makes sense.  Steve, can you look into this for supported releases (like
> F12 and RHEL5)?  Or, perhaps you can clarify why that "rm" is required.
I know at the time I added that code the pid file was not being
removed and by explicitly removing it caused sm-notify to *always* run 
which, at the time, seem like the right thing to do.. The change was 
made in early January of 08, so let me take to see if things 
have changed... 

steved.
