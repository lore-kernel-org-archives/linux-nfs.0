From: Matthew Moldvan <mmoldvan@trilogyintl.com>
Subject: Re: Solaris 8 to Linux Red Hat 9 - NFS Goes up and down and
	up and do wn ...
Date: Thu, 18 Sep 2003 11:22:19 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1063898538.31782.22.camel@matt>
References: <2840B2764868D51189420090277B7699FD8F30@trilogy_pub.trilogyintl.com>
Reply-To: mmoldvan@trilogyintl.com
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A00cX-0000Xg-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 08:23:01 -0700
Received: from [209.187.237.19] (helo=proxy.trilogyintl.com)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A00cW-0006nU-IA
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 08:23:00 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <2840B2764868D51189420090277B7699FD8F30@trilogy_pub.trilogyintl.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

FYI, we figured this out.

Our problem didn't have to do with NFS, it was APM daemons that were
running ... we had to boot with apm=off as a boot option to disable the
kernal apmd (kapmd) and do service apmd stop and chkconfig etc etc. to
disable all of the APM stuff.

That was it!

Horray!

We now return you to your regularly scheduled NFS talk.

Regards,
Matthew Moldvan.

System Administrator
Trilogy International, Inc.

On Mon, 2003-08-25 at 10:39, Matthew Moldvan wrote:
> Hi everyone,
> 
> I've finally just about given up on trying to figure this out myself ...
> here's my issue:
> 
> We have a Sun E450 running Solaris 8 with not enough disk space on a few of
> the partitions.  Our solution: an x86 machine running Red Hat 9 with a 3Ware
> Escalade 4 port IDE RAID card and a few big HDDs.
> 
> So, we have the two machines communicating just fine through a Gigabit
> ethernet interface with a subnet.  Now, we've tried the rest two ways: 
> 
> 	1. Our E450 mounts the RH9 NFS share, then exports that as it's own
> NFS share
> 		or
> 	2. We mount the RH9 NFS share directly from the other Solaris
> workstations
> 
> Now, the issue we're facing is this: The whole setup works fine for awhile,
> with a minor amount of collisions ... BUT, after a few hours, the whole
> thing falls apart.  Workstations can't login because NFS shares aren't being
> mounted, the main server is not allowing connections because it can't mount
> the NFS itself, etc etc etc.
> 
> This is all incredibly frustrating to me, and we've tried everything from
> changing the gigabit ethernet configuration to trying new network cards to
> blaming it on wiring to god knows what now ...
> 
> Any ideas??
> 
> Regards,
> Matthew Moldvan
>  
> System Administrator
> Trilogy International, Inc.
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: VM Ware
> With VMware you can run multiple operating systems on a single machine.
> WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines
> at the same time. Free trial click here:http://www.vmware.com/wl/offer/358/0
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
