From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: IPv6 support: dreaming of...
Date: Thu, 19 Nov 2009 11:05:55 -0500
Message-ID: <46303206-4A71-4FE8-BAC6-52281B8FB055@oracle.com>
References: <4AEE9645.6010503@suse.de> <B3F6BEAE-A564-475F-93D5-7D6E0FC79147@oracle.com> <87hbsqbl3d.fsf_-_@violet.siamics.ipv6.uusia.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Ivan Shmakov <ivan-tPYS1JDixHzCyp4qypjU+w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:37578 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753469AbZKSQGW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Nov 2009 11:06:22 -0500
In-Reply-To: <87hbsqbl3d.fsf_-_-Hr8DDCuc/25fzK4uoAgqGcYP0srqJqIshoJSb6RVeLg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, Ivan.  That echoes my own concept of a basic NFS over IPv6  
deployment use case.

On Nov 19, 2009, at 10:17 AM, Ivan Shmakov wrote:

>>>>>> "CL" == Chuck Lever <chuck.lever...> writes:
>>>>>> "SJ" == Suresh Jayaraman wrote:
>
> 	... And first of all: it seems that there're an immense amount
> 	of work being done to add the NFS over IPv6 support for
> 	GNU/Linux.  Thanks for that!
>
> [...]
>
> SJ> How far we are from getting full IPv6 support?
>
> CL> The short answer is mountd/exportfs will take about six months.
> CL> The client side is close enough that I think we can promise basic
> CL> IPv6 support for upcoming enterprise releases.  We're also  
> thinking
> CL> the kernel work on the server is close enough that few or no kABI
> CL> changes will be needed once mountd is working, but that's just a
> CL> guess.
>
> CL> The long answer depends on your definition of "full".  :-)
>
> 	Well, I'll try to answer to it based on my own use of NFS
> 	(mostly NFSv3, at this moment), as was suggested.
>
> 	Basically, every now and then I have to set up some shared
> 	filesystem-like resources.  To this end, I usually deploy (at
> 	the same time):
>
> 	* HTTP, for its ubiquity;
>
> Alias /public /var/public
>
> <Directory /var/public>
>    Options Indexes SymLinksIfOwnerMatch IncludesNoExec ExecCGI
>    AllowOverride FileInfo AuthConfig Limit
> </Directory>
>
> 	* Rsync, for its superior handling of replication;
>
> [public]
> 	path		= /var/public
> 	comment		= Public directory
>
> 	* NFS, for it requires no specific support from the applications
> 	  themselves.
>
> /var/public		*(ro,all_squash,async,insecure)
> /var/public/debian	*(ro,all_squash,async,insecure)
> /var/public/storage	*(ro,all_squash,async,insecure)
>
> 	Mostly, these are used to conserve disk space by allowing a few
> 	copies of certain files to be used by a number of users.  Rarely
> 	I need to maintain anything writable, and if possible, prefer to
> 	deploy SSH/SFTP for ``uploading''.
>
> 	I need almost no access management, as most of the data was
> 	received from open sources (say, http://www.debian.org/,
> 	http://www.landcover.org/ or http://wist.echo.nasa.gov/), and
> 	there were no DoS-doers or bandwidth hogs so far.
>
> 	Actually, even NFSv3 suits my needs almost completely, though
> 	occasionally I need Kerberos.
>
> CL> Does that include complete support for link-local IPv6 addresses?
>
> 	No.  Not for me, at the least.  IIUC, these are to be used
> 	mainly for low-level network services and testing.  It could be
> 	handy to support these widely, but I'd not make it a priority
> 	task.
>
> CL> Does that include full support for netids in the kernel?
>
> 	No clue on this, sorry.
>
> CL> Does that include complete multi-homed host support in lockd and
> CL> statd?
>
> 	I believe that multi-homing is going to be more likely in IPv6
> 	environments.  I've never experimented with NFS on multi-homed
> 	IPv4 hosts, though, so I'm not sure what's meant by ``complete
> 	support'' here.
>
> CL> Does that include full support for internationalized domain names?
>
> 	Not for me.
>
> CL> Does that include IPv6 netgroup support?
>
> 	Do you mean netgroup like in NIS (or LDAP with a NIS-like
> 	schema)?  These also could be handy, but not a priority task, at
> 	least for me.
>
> CL> Does it include IPv6 support in TCP wrappers?
>
> 	In general, I see TCP wrappers as, roughly, a functional
> 	equivalent of netfilter / ip6tables(8).  So, once again, not a
> 	priority for me.  (If I don't miss something.)
>
> CL> Does it include support for systems that have no IPv4 addresses
> CL> (not even loopback)?
>
> 	Absolutely.  But it surely can wait.
>
> CL> There are a bunch of details that still need to be worked through.
> CL> I've only been able to guess at what features are required, and
> CL> which can be implemented at a later time.  What I would dearly  
> love
> CL> to have is a list of specific features that folks feel is a
> CL> baseline (based on actual data, of course).
>
> 	Hopefully, the bits above will help.
>
> CL> Unfortunately there are very few Linux customers who have deployed
> CL> IPv6 and an IPv6-capable NFS implementation (like Solaris) and can
> CL> tell us what they would need on Linux.
>
> 	It seems that my brother's going to do me a favor and install
> 	OpenSolaris for me (which, as I saw today, is being able to
> 	export and mount filesystems using NFS over IPv6.)
>
> 	(I wonder, are there Apache and Rsync bundled with OpenSolaris?)
>
> 	Perhaps I'll be able to experiment with some (up to 20 or so)
> 	Debian GNU/Linux hosts using it as a file server.
>
> CL> Plus, most distributions don't have fluent user space
> CL> infrastructure for IPv6 yet.  NetworkManager is one area that may
> CL> need work.  The Network Administration tool in Fedora is still
> CL> IPv4-centric, iirc.
>
> 	... And, unfortunately, even interfaces(5) handling in Debian
> 	has flaws in that respect.  Sigh.
>
> CL> We don't have firewall admin tools that handle IPv6 rules.
>
> 	Personally, I prefer ip6tables(8), which does.
>
> CL> Unlike IPv4, admins can (and often do) use IPv6-aware kernels
> CL> without ipv6.ko, so all of our tools and support have to be  
> careful
> CL> about using IPv6 when the O/S may not support it.  This is
> CL> different than IPv4, which is nearly always available.
>
> 	Agreed.
>
> CL> In other words, system support for IPv6 outside of NFS is kind of
> CL> like wireless was 5 years ago -- innumerable small admin tools  
> that
> CL> users had to integrate themselves, usually without much success.
>
> -- 
> FSF associate member #7257
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



