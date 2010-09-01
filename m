Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao106.cox.net ([68.230.240.48]:45622 "EHLO
	eastrmmtao106.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659Ab0IAVwi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Sep 2010 17:52:38 -0400
Message-ID: <4C7ECB23.60300@excfb.com>
Date: Wed, 01 Sep 2010 16:52:35 -0500
From: Tom Haynes <tdh@excfb.com>
To: Greg <greg-sys@duchatelet.net>
CC: linux-nfs@vger.kernel.org
Subject: Re: Relocate NFS root FS for maintenance
References: <4C7E4469.70807@duchatelet.net>
In-Reply-To: <4C7E4469.70807@duchatelet.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  On 9/1/2010 7:17 AM, Greg wrote:
>  Hi,
>
> I don't know if it is the good place to ask for such a problem, if not 
> please apologize.
>
> I have a pseudo active/active NFSv4 configuration: 2 NFSv4 servers 
> (1:1.1.2-6lenny1), exporting 3 filesystems. Each filesystem are 
> connected to a SAN volume, via iscsi and multipath.
>
> filer-01 :
> /var/local                      
> 10.0.0.0/16(rw,fsid=0,crossmnt,insecure,async,no_subtree_check)
> /var/local/large            
> 10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=3)
>
> filer-02 :
> /var/local                      
> 10.0.0.0/16(rw,fsid=0,crossmnt,insecure,async,no_subtree_check)
> /var/local/small           
> 10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=1)
> /var/local/medium      
> 10.0.0.0/16(rw,insecure,async,no_subtree_check,no_root_squash,fsid=2)
>
> filer-01 share a volume on the first SAN, filer-02 share 2 volumes on 
> the second SAN.
>
> I have to do a firmware upgrade on the SANs, so I have to umount 
> /var/local/* on the nfs servers. On way could be to relocate NFS root 
> FS from /var/local to /var/maintenance with empty directories large, 
> medium and small
> But how to do that ? I try to change /etc/exports then exportfs -rvf, 
> but got "Stale NFS file handle" on clients...
>
> If not, is there a better way to do that, without to shutdown NFS 
> servers ?
>

Greg,

What you are missing here is that the client uses two things to access 
content on
the servers - path and file handles. When you do the reshare, you would 
be pointing any
new requests to the empty directories. But, any application which 
already had a
file handle would have a reference to the old mount (via the fsid part 
of the file handle).

The client is detecting that the old mount is no longer being exported 
by the server, so
it replies with ESTALE.

The options I see are to:

1) Shutdown NFS/remove write access to the export/etc - this is along 
the lines of what
you have done. And the result is that the server will inform the client 
of an error.

2) Disconnect the servers from the network. (Or partition the network). 
In this scenario,
the client will be getting timeouts and will probably use a retry schema.

3) Shutdown the NFS clients - harsh, but they will not be accessing the 
servers and you
can easily do the upgrades.

These all result in downtime for both your servers and your clients.

A long term solution will be possible when replication is realized 
within the server and
clients. It is a protocol feature which I do not think is implemented yet.

Tom
