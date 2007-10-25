From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: LTP ustat01 test fails on NFSROOT
Date: Thu, 25 Oct 2007 10:59:53 -0500
Message-ID: <2B2C1270-60FB-4830-A62C-D0357D2E1FB3@kernel.crashing.org>
References: <CBDE987B-0713-4D62-8122-054183E75410@kernel.crashing.org>
	<1193188894.27073.20.camel@heimdal.trondhjem.org>
	<1954B8FA-6E29-4FB7-86B0-EA43AF8F2AAF@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Il57F-0005Gb-K4
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 08:59:25 -0700
Received: from gate.crashing.org ([63.228.1.57]
	ident=[U2FsdGVkX18A7P5BO3dbXvYRjUxGy4e6SlmX4WNtppw=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Il57I-000379-PJ
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 08:59:31 -0700
In-Reply-To: <1954B8FA-6E29-4FB7-86B0-EA43AF8F2AAF@kernel.crashing.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Oct 24, 2007, at 12:05 AM, Kumar Gala wrote:

>
> On Oct 23, 2007, at 8:21 PM, Trond Myklebust wrote:
>
>>
>> On Tue, 2007-10-23 at 17:52 -0500, Kumar Gala wrote:
>>> I'm looking into an issue with LTP's ustat01 & ustat02 tests in  
>>> which
>>> they report the following:
>>>
>>> ustat01     1  FAIL  :  ustat(2) failed and setthe errno to 116 :
>>> Stale NFS file handle
>>> ustat02     2  FAIL  :  ustat(2) failed to produce expected error;
>>> 14, errno: EFAULT and got 116
>>>
>>> It appears sometime between 2.6.21 and 2.6.22-rc1 some changes to  
>>> NFS
>>> got introduced that cause this.
>>>
>>> was wondering about any ideas while I try to debug what's going on.
>>>
>>> thanks
>>>
>>> - k
>>
>> I'm seeing zero problems with the latest checkouts from Linus' git  
>> tree.
>> Mind giving us some more details?
>
> I tried 2.6.24-rc1 w/the same result.
>
> The system is a 32-bit PPC embedded board that we mounting the  
> rootfs over nfs on.
>
> The defconfig is arch/powerpc/configs/mpc8641_hpcn_defconfig
>
>> 'strace' output would be useful, as would the standard NFS list of
>> client mount options, server export options, details on how your
>> exported partition is set up on the server, etc...
>
> strace:
>
> stat64("/", {st_dev=makedev(0, 14), st_ino=58821800,  
> st_mode=S_IFDIR|0775, st_nlink=18, st_uid=500, st_gid=500,  
> st_blksize=4096, st_blocks=8, st_size=4096,  
> st_atime=2007/10/23-22:43:30, st_mtime=2007/10/18-19:51:19,  
> st_ctime=2007/10/18-19:51:19}) = 0
> ustat(0xe, 0x1001a008)                  = -1 ESTALE (Stale NFS file  
> handle)
> fstat64(1, {st_dev=makedev(0, 14), st_ino=58821964, st_mode=S_IFCHR| 
> 0600, st_nlink=1, st_uid=0, st_gid=0, st_blksize=4096, st_blocks=0,  
> st_rdev=makedev(4, 64), st_atime=2007/10/16-18:32:59,  
> st_mtime=2007/10/16-18:32:59, st_ctime=2007/10/24-05:03:34}) = 0
>
>
> Info on the server:
>
> [root@ducky ~]# exportfs -v
> /               <world> 
> (rw,async,wdelay,no_root_squash,no_subtree_check)
> [root@ducky ~]# uname -a
> Linux ducky.am.freescale.net 2.6.22.5-76.fc7 #1 SMP Thu Aug 30  
> 13:04:34 EDT 2007 ppc64 ppc64 ppc64 GNU/Linux
>
> On the host system:
>
> (not sure how to get client mount options, mount reports:
>
> %root% on / type unknown (rw)
>
> -sh-2.05b# cat /proc/cmdline
> root=/dev/nfs rw nfsroot=192.168.1.15:/home/galak/ltib-joust-8572/ 
> rootfs  
> ip=192.168.1.147:192.168.1.15:192.168.1.1:255.255.254.0:rocky:eth0:off 
>  console=ttyS0,115200
>
> If there is some other info that would be useful please let me know.

any ideas?  any other debug info needed?

- k

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
