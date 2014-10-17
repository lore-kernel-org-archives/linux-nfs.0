Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:37778 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbaJQQPz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Oct 2014 12:15:55 -0400
Received: by mail-pd0-f172.google.com with SMTP id ft15so1034671pdb.31
        for <linux-nfs@vger.kernel.org>; Fri, 17 Oct 2014 09:15:54 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: when rpc.mountd flushes auth.unix.gid
From: Tom Haynes <thomas.haynes@primarydata.com>
In-Reply-To: <54412AC6.7070000@cs.uchicago.edu>
Date: Fri, 17 Oct 2014 11:15:50 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <EB1CCA15-1DFB-454B-A7C7-061164B72DB7@primarydata.com>
References: <54412AC6.7070000@cs.uchicago.edu>
To: Colin Hudler <chudler@cs.uchicago.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 17, 2014, at 9:42 AM, Colin Hudler <chudler@cs.uchicago.edu> wrote:

> We have a few hundred computers mounting an NFS server in a typical LDAP-based users (nss) setup. We frequently add and remove exports and use exportfs -r to update stab.

I know this isn’t your question, but you would be better served by using explicit exportfs -a and exportfs -r commands for the specific changes.



> Every time we do so, the clients report "NFS server not responding" and start backing off their requests. After a painful 3-5 minutes, they recover and life is normal again.
> 
> We discovered that when the rpc.mountd cache flushing occurs, our NIS system is overwhelmed with grouplist requests and this obviously blocks things. We are working on that problem separately, and I admit this to be a weakness in our setup. My question is simple.
> 
> Why does it flush auth.unix.gid when the etab changed? I think it makes unnecessary work for rpc.mountd because the gids are unlikely to have changed,

Another assumption is that exports rarely change. I expect your setup is an exception to the rule.


> and they already have a reasonable expiration policy.

One way to read what the man page states for exportfs -r:

       -r     Reexport  all  directories,  synchronizing  /var/lib/nfs/etab with /etc/exports and files under /etc/exports.d.
              This option removes entries in /var/lib/nfs/etab which have been  deleted  from  /etc/exports  or  files  under
              /etc/exports.d, and removes any entries from the kernel export table which are no longer valid.

is that it only removes entries which have been deleted.

Instead, it removes all entries and reexports those that are still valid. The remove of all is what blows away the auth.unix.gid caching.

Using exportfs -a <path> and exportfs -r <path> should solve this for you.




> 
> --
> Colin
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

