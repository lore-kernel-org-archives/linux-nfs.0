Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx.cs.uchicago.edu ([128.135.164.214]:49204 "EHLO
	mx.cs.uchicago.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbaJQSTq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 14:19:46 -0400
Received: from localhost (localhost [127.0.0.1])
	by mx.cs.uchicago.edu (Postfix) with ESMTP id 522C065215
	for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 13:19:45 -0500 (CDT)
Received: from mx.cs.uchicago.edu ([127.0.0.1])
	by localhost (mx.cs.uchicago.edu [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id OZ6AZopa4ASA for <linux-nfs@vger.kernel.org>;
	Fri, 17 Oct 2014 13:19:44 -0500 (CDT)
Received: from [128.135.11.26] (derby.cs.uchicago.edu [128.135.11.26])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx.cs.uchicago.edu (Postfix) with ESMTPSA id AA59365189
	for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 13:19:44 -0500 (CDT)
Message-ID: <54415DC0.4030300@cs.uchicago.edu>
Date: Fri, 17 Oct 2014 13:19:44 -0500
From: Colin Hudler <chudler@cs.uchicago.edu>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: when rpc.mountd flushes auth.unix.gid
References: <54412AC6.7070000@cs.uchicago.edu> <EB1CCA15-1DFB-454B-A7C7-061164B72DB7@primarydata.com>
In-Reply-To: <EB1CCA15-1DFB-454B-A7C7-061164B72DB7@primarydata.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/17/2014 11:15 AM, Tom Haynes wrote:
>
> On Oct 17, 2014, at 9:42 AM, Colin Hudler <chudler@cs.uchicago.edu> wrote:
>
>> We have a few hundred computers mounting an NFS server in a typical LDAP-based users (nss) setup. We frequently add and remove exports and use exportfs -r to update stab.
>
> I know this isn’t your question, but you would be better served by using explicit exportfs -a and exportfs -r commands for the specific changes.
>

Thank you for the insight and suggestions. We are considering changing 
our methods but it requires breaking some (long-standing, internal) 
abstractions and weighing the risk associated with that. In short, our 
automations suck and cannot be changed so easily. However, manual-mode 
is always an option.

>
>
>> Every time we do so, the clients report "NFS server not responding" and start backing off their requests. After a painful 3-5 minutes, they recover and life is normal again.
>>
>> We discovered that when the rpc.mountd cache flushing occurs, our NIS system is overwhelmed with grouplist requests and this obviously blocks things. We are working on that problem separately, and I admit this to be a weakness in our setup. My question is simple.
>>
>> Why does it flush auth.unix.gid when the etab changed? I think it makes unnecessary work for rpc.mountd because the gids are unlikely to have changed,
>
> Another assumption is that exports rarely change. I expect your setup is an exception to the rule.
>
>
>> and they already have a reasonable expiration policy.
>
> One way to read what the man page states for exportfs -r:
>
>         -r     Reexport  all  directories,  synchronizing  /var/lib/nfs/etab with /etc/exports and files under /etc/exports.d.
>                This option removes entries in /var/lib/nfs/etab which have been  deleted  from  /etc/exports  or  files  under
>                /etc/exports.d, and removes any entries from the kernel export table which are no longer valid.
>
> is that it only removes entries which have been deleted.
>
> Instead, it removes all entries and reexports those that are still valid. The remove of all is what blows away the auth.unix.gid caching.
>
> Using exportfs -a <path> and exportfs -r <path> should solve this for you.


Understood. I am now tempted to rework exportfs -r into a loop over 
dump(). Thanks again.
