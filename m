Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bronze.cs.yorku.ca ([130.63.90.34]:58790 "EHLO
	bronze.cs.yorku.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755921Ab0JDNvj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Oct 2010 09:51:39 -0400
Message-ID: <4CA9D4BC.1060201@cse.yorku.ca>
Date: Mon, 04 Oct 2010 09:21:00 -0400
From: Jason Keltz <jas@cse.yorku.ca>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: hang on existing systems when exporting NFS share to new systems
References: <4C503450.1010609@cse.yorku.ca> <20100728174241.GB19362@fieldses.org> <4C53855F.5060201@cse.yorku.ca> <20101003211322.GC15339@fieldses.org>
In-Reply-To: <20101003211322.GC15339@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Fri, Jul 30, 2010 at 10:07:27PM -0400, Jason Keltz wrote:
>> On 28/07/2010 1:42 PM, J. Bruce Fields wrote:
>>> On Wed, Jul 28, 2010 at 09:44:48AM -0400, Jason Keltz wrote
>>> My list of NFS exports has been gradually growing over the years.
>>> Right now, for example, my home directories are exported to around
>>> 800 hosts. (although only a relatively small subset of those will
>>> mount at the same time...).  I used to just add hosts to
>>> /etc/exports on the file server, and run "exportfs -r", and
>>> everything would be fine.  New systems would be able to mount
>>> everything perfectly, and existing systems would not be affected at
>>> all.  As the list has grown, I've been noticing a problem. Now, when
>>> I run exportfs -r, there is an approximate 7-10 second hang on the
>>> systems that have already mounted the share, and then everything
>>> returns to normal.  This doesn't happen *while* exportfs -r is
>>> running, but just after it exits.  I figured that maybe exportfs was
>>> "unexporting"/re-exporting to hosts that already had the share in
>>> use which might have caused the problem, so I tried to manually
>>> add/remove hosts thinking that this would only affect those hosts,
>>> but it did not. Exporting to one new host still causes the hang on
>>> all existing hosts.
>>>
>>> Since I have multiple exports to all of the hosts, adding one new
>>> host can hang things for a while.  I can see that reducing the list
>>> of exports, or hosts would reduce the delay.  What I am wondering is
>>> if there is a better way that I can add hosts without affecting
>>> connectivity to existing hosts?
>>>
>>> The NFS server itself is pretty powerful -- dual quad core box, lots
>>> of memory, many NFS threads, exclusive NFS server, etc...  I am
>>> running an older RHEL4 release though, so it would have an older
>>> kernel/NFS system.  Maybe this issue has been solved in newer
>>> releases.
>>> There have been fixes in this area, though I don't see any that I'm sure
>>> would address your problem.  If you could test with the latest nfs-utils
>>> (ideally, with the latest nfs-utils and kernel) and let us know the
>>> result, that would be helpful.
>>>
>>> The -t option to rpc.mountd (may need a newer nfs-utils?) may also help.
>>>
>>> Also worth filing an RHEL bug.
>> Hi Bruce,
>>
>> I backported the -t option to RHEL4 by looking at the latest
>> nfs-utils, but it didn't fix the problem.
>> I'm having trouble compiling the latest nfs-utils for RHEL4 because
>> a couple of changed libraries...
>>
>> What I have learned:
>>
>> 1) whether exportfs -r, or manually add a single host with exportfs,
>> or even remove a host with exportfs -u, the delay to all the clients
>> is the same.  The delay doesn't change depending on the share.
>> 2) the delay doesn't happen while exportfs is running.  It happens
>> immediately afterwards, and when it does happen, an strace of
>> rpc.mountd shows that rpc.mountd is busy resolving every single
>> hostname in etab.. on one of our NFS servers, this means a total of
>> 13,000 DNS requests... on another system, that's over 30,000 DNS
>> requests (and around a 30 second delay to all shares).  Once
>> rpc.mountd stops burdening the DNS, that's exactly when activity on
>> all the shares returns.
>> 3) I've tried to change /etc/exports to use just IP... but exportfs
>> happily switches etab back to using hostnames, and then mountd does
>> all the lookups again...
>>
>> I suppose that the reason why exportfs doesn't convert etab to just
>> use IPs in the first place is because a name can resolve to multiple
>> IPs... but if I start with a list of IPs in /etc/exports, it would
>> be nice if they just stayed like that in etab, and if mountd could
>> use them as is... what's the point of all the DNS requests? (first
>> to generate etab, then from mountd a second time!)
>>
>> The only thing I can think to try at this point would be to see if I
>> populated /etc/hosts locally on the file server to see if the timing
>> works better than the DNS requests.
>>
>> If someone has any suggestions, I'd love to hear them.
> 
> Did you ever figure out anything more about the problem?

Hi Bruce,

Actually, since I was sharing out over a private network, I did not need 
to include every address in the list, and was able to use an IP range. 
Now, I share out to pretty much the same host list, but export is 
instantaneous.  I still believe that I *should* have been able to export 
to the large number of hosts without the tremendous delay, but I was not 
able to solve the problem with my current (RHEL4) installation.  We will 
upgrade to RHEL6 when it's available, so I might try again with that 
just for fun.

Jason.
