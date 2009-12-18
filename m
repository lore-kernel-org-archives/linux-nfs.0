From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [RFC] server's statd and lockd will not sync after its nfslock restart
Date: Fri, 18 Dec 2009 10:18:46 -0500
Message-ID: <E8858040-69E2-4F09-A369-92713BF57161@oracle.com>
References: <4B275EA3.9030603@cn.fujitsu.com> <F9F5EA38-B51C-44A4-9812-873EEE1891C9@oracle.com> <4B28B5FD.5000103@cn.fujitsu.com> <E6EC8330-4C4C-4917-AEE3-A2BEE35B9F8A@oracle.com> <4B2A02C6.6080501@cn.fujitsu.com> <35D45F43-D98F-460E-8060-F7C5F3ADFCFE@oracle.com> <20091218101438.48eb06a4@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "Trond.Myklebust Myklebust" <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	Mi Jinlong <mijinlong@cn.fujitsu.com>
To: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:26523 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbZLRPTo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Dec 2009 10:19:44 -0500
In-Reply-To: <20091218101438.48eb06a4-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Dec 17, 2009, at 6:14 PM, Neil Brown wrote:

> On Thu, 17 Dec 2009 11:18:53 -0500
> Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> Jeff Layton pointed out to me yesterday that Red Hat's nfslock script
>> unconditionally deletes sm-notify's pid file every time "service
>> nfslock start" is done, which effectively defeats sm-notify's reboot
>> detection.
>>
>> sm-notify was written by a developer at SuSE.  SuSE Linux uses a  
>> tmpfs
>> for /var/run, but Red Hat uses permanent storage for this directory.
>> Thus on SuSE, the pid file gets deleted automatically by a reboot,  
>> but
>> on Red Hat, the pid file must be deleted "by hand" or reboot
>> notification never occurs.
>
> Just to make sure the facts are straight:
> SuSE does not use tmpfs for /var/run (much as I personally think that
> would be a very sensible approach for both /var/run and /var/locks).
> It appears that Debian can use tmpfs for these, but doesn't by  
> default.
>
> Both SuSE and Debian have boot time scripts that clean up /var/run  
> and other
> directories.  They remove all non-directories other than /var/run/ 
> utmp.
>
> If Redhat doesn't clean up /var/run at boot time, then I would think  
> that is
> very odd.  The files in there represent something that is running.   
> At boot,
> nothing is running, so it should all be cleaned up.  Are you sure  
> Redhat
> doesn't clean out /var/run???
>
> I just had a look at master.kernel.org (the only fedora machine I  
> can think
> of that I have access to) and in /etc/rc.d/rc.sysinit I find
>
>    find /var/lock /var/run ! -type d -exec rm -f {} \;
>
> So I'm thinking that if you just remove
>
>        # Make sure locks are recovered
>        rm -f /var/run/sm-notify.pid
>
> from /etc/init.d/nfslock, then it will do the right thing.

Makes sense.  Steve, can you look into this for supported releases  
(like F12 and RHEL5)?  Or, perhaps you can clarify why that "rm" is  
required.

Meanwhile, I'm going to prototype a mechanism that tries to use the  
kernel's boot_id, if present.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




