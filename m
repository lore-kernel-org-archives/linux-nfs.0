From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] nfs(5): Document remount behavior (take 2)
Date: Fri, 29 Oct 2010 12:36:31 -0400
Message-ID: <9088B538-D542-4895-A58E-23EF4BBB0351@oracle.com>
References: <20101029154029.2719.14791.stgit@matisse.1015granger.net> <4CCAF26C.3030007@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v1081)
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:24919 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757875Ab0J2Qiq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Oct 2010 12:38:46 -0400
In-Reply-To: <4CCAF26C.3030007-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 29, 2010, at 12:12 PM, Steve Dickson wrote:

> 
> 
> On 10/29/2010 11:42 AM, Chuck Lever wrote:
>> It appears that, for a long while, NFS "remount" mounts have
>> completely wiped the existing mount options in /etc/mtab for a given
>> mount point.  This is a problem for umount.nfs, since it reads its
>> options out of /etc/mtab to find out how to do the unmount.
>> 
>> The mount(8) command provides the NFS mount subcommand with the mount
>> options to perform the remount.  There are four cases to consider:
>> 
>>  1. Both the device and mount directory are specified on the
>>     command line, and the target mount point is in /etc/fstab
>> 
>>  2. Only one of the device and mount directory is specified on
>>     the command line, and the target mount point is in
>>     /etc/fstab
>> 
>>  3. Both the device and mount directory are specified on the
>>     command line, and the target mount point is not in /etc/fstab
>> 
>>  4. Only one of the device and mount directory is specified on
>>     the command line, and the target mount point is not in
>>     /etc/fstab
>> 
>> Currently only case 4 works correctly.  In that case, mount(8)
>> provides the correct set of mount options to the mount.nfs
>> subcommand and it can update /etc/mtab correctly.
>> 
>> Cases 1 and 3 replace all mount options in /etc/mtab with the options
>> provided on the command line during a remount.  Case 2 replaces the
>> mount options in /etc/mtab with a mix of options from /etc/fstab and
>> /etc/mtab.
>> 
>> Cases 1 and 3 are historical behavior.  Basically this is a formal
>> interface to allow administrators to replace the mount options in
>> /etc/mtab completely, instead of merging in new ones.  The present
>> patch documents that behavior in nfs(5), and provides best practice
>> for remounting NFS mount points.
>> 
>> There are near-term plans to address case 2 by fixing mount(8)
>> (provided by utils-linux-ng in most distributions).
>> 
>> This is a partial fix for:
>> 
>>  https://bugzilla.linux-nfs.org/show_bug.cgi?id=188
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> Take 2:
>> 
>> o  Remove mentions of /etc/mtab
>> 
>> o  Refocus new umount subsection on umount requirements rather than
>>    remount syntax
> First of all... Thank you, very much, for reconsidering this....
> 
> Secondly, unfortunately I don't see much difference between
> this one and the first posting... what am I missing? 

D'oh.  stgit will allow you to e-mail a patch while the working directory is dirty.  I ended up posting the same patch as yesterday.  Will try again.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




