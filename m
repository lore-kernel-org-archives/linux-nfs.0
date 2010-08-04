Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bronze.cs.yorku.ca ([130.63.90.34]:55211 "EHLO
	bronze.cs.yorku.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932320Ab0HDNrq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 09:47:46 -0400
Message-ID: <4C596F81.6010409@cse.yorku.ca>
Date: Wed, 04 Aug 2010 09:47:45 -0400
From: Jason Keltz <jas@cse.yorku.ca>
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: exporting to a list of IPs
References: <4C583B63.4050903@cse.yorku.ca> <20100804134527.146397ff@notabene>
In-Reply-To: <20100804134527.146397ff@notabene>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Neil Brown wrote:
> On Tue, 03 Aug 2010 11:53:07 -0400
> Jason Keltz <jas@cse.yorku.ca> wrote:
> 
>> Hi.
>>
>> Why is it that you cannot NFS export to a list of IPs and have exportfs 
>> leave the list of IPs in etab without converting over to FQDN?
> 
> My memory is that if you only list IP addresses in /etc/exports then it will
> do just want you want.  But if you list any host names or net groups then it
> has to do a DNS lookup on everything to see if either of those matches.

Hi Neil.

Thanks for your response!

Actually, if I list ONLY IPs in /etc/exports, and nothing else, then 
etab gets converted over to using hostnames:

For example:

# cat /etc/exports
/test 130.63.92.24(ro,sync)

# cat /var/lib/nfs/etab
(it's empty)
# exportfs -a
# cat /var/lib/nfs/etab
/test 
gold.cs.yorku.ca(ro,sync,wdelay,hide,nocrossmnt,secure,root_squash,no_all_squash,subtree_check,secure_locks,mapping=identity,anonuid=-2,anongid=-2)

In fact, I see two problems here.  First, exportfs shouldn't convert 
etab over to using FQDN.  Second, if it does do this, I don't see why 
rpc.mountd needs to RE-resolve each hostname in etab.    During this 
time (right after exportfs exits), all of my NFS shares hang, and an 
strace of rpc.mountd shows that it is re-resolving all the hostnames 
from etab.  When it finishes, all activity continues.  On one system 
with a total of 30,000 hostnames listed, this ends up in a 30 second 
hang time for all NFS exports!  I was able to shrink this time slightly 
by putting a caching name server on the NFS server, so that the NFS 
server wasn't killing the DNS, but this didn't help enough.  If exportfs 
truly has to convert IPs over to hostname, I can live with that, but 
then rpc.mountd shouldn't re-resolve the names.  If both can live with 
IPs, I'm good with that as well.

Now, albeit, I'm using an older nfs-utils that comes with RHEL4 
installation.  Compiling a later version is a bit tricky because some 
libraries have changed.  That being said, reviewing the source (given 
that I don't really know it that well) for the newest nfs-utils, I don't 
see how this behavior would really be any different.  For example, in 
client_lookup in support/export/client.c, adding some printfs, I can see 
that the IPs always get into the ...

   if (htype == MCL_FQDN && !canonical) {
... where there's a call to gethostbyname.

This is the same in nfs-utils-1.0.6 as it is in 1.2.2.

>> Why does mountd need to repeat the gethostbyname() lookup on every host 
>> even though exportfs already converted over to using hostname?
> 
> exportfs doesn't convert over host hostnames.  It essentially
> copies /etc/exports to /var/lib/nfs/etab with minor formatting changes.
> 
> What do you actually put in /etc/exports, what do you find
> in /var/lib/nfs/etab, and what exactly is the problem?
> 
> NeilBrown

See above.. thanks :)

Jason.

