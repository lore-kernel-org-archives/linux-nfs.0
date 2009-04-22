From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils-1.1.6 released.
Date: Wed, 22 Apr 2009 11:40:51 -0400
Message-ID: <49EF3A83.50409@RedHat.com>
References: <49ECB9E6.4010001@RedHat.com> <49EDFE21.2000007@arx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Thanos Chatziathanassiou <tchatzi-nz9JlX+3IF8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:58627 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbZDVPnr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Apr 2009 11:43:47 -0400
In-Reply-To: <49EDFE21.2000007-nz9JlX+3IF8@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Thanos Chatziathanassiou wrote:
> Installed nfs-utils-1.1.6 and I'm facing an issue:
> 
> on the server:
> # cat /etc/exports
> /opt/shared/home
> 192.168.99.0/255.255.255.0(rw,no_root_squash,no_subtree_check,sync)
> 
> # cat /var/lib/nfs/etab
> /opt/shared/home   
> 192.168.99.0/255.255.255.0(rw,sync,wdelay,hide,nocrossmnt,secure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,acl,anonuid=65534,anongid=65534)
> 
> 
> on the client:
> # cat /proc/mounts
> nfsip:/opt/shared/home /home nfs
> rw,noatime,vers=3,rsize=8192,wsize=8192,hard,intr,proto=udp,timeo=11,retrans=2,addr=nfsip
> 0 0
> 
> however, everyone (including root) gets mapped to uid 65534 despite
> no_root_squash and no_all_squash...not very useful for a home directory.
> Is there something I'm missing ?
Wow... That is very strange... 

any type of failures in /var/log/messages?

> Also tried to go back to the previous (1.1.1) nfs-utils, but after
> ``exportfs -ra'' the the server spit a few of those and all mounts froze
> nfs mountd[1115]: /var/lib/nfs/etab:1: unknown keyword "mapping=identity"
I don't see a 'mapping' entry in the above 'cat /var/lib/nfs/etab'? 

steved.
