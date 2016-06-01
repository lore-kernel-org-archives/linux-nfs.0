Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:39854 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981AbcFANCL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Jun 2016 09:02:11 -0400
Date: Wed, 1 Jun 2016 09:02:10 -0400
To: Matthias Leopold <matthias.leopold@meduniwien.ac.at>
Cc: linux-nfs@vger.kernel.org
Subject: Re: getattr ERROR: Request couldn't be completed in time
Message-ID: <20160601130210.GD3387@fieldses.org>
References: <574D7F26.1090202@meduniwien.ac.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <574D7F26.1090202@meduniwien.ac.at>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 31, 2016 at 02:10:14PM +0200, Matthias Leopold wrote:
> hi,
> 
> i'm trying to mount a NFS 4 share with "sec=sys" from a NetApp
> FAS3250 on a CentOS KVM guest. this doesn't work, the mount doesn't
> complete and hangs.
> 
> mount command is:
> /bin/mount -v -t nfs -s -o vers=4.1,sec=sys 10.110.96.90:/home /home/cir
> 
> what i'm seeing in tcpdump is:
> 
> 08:36:48.875019 IP 10.110.96.112.2456702824 > 10.110.96.90.2049: 212
> getattr fh 0,1/53
> 08:36:48.875355 IP 10.110.96.90.2049 > 10.110.96.112.2456702824:
> reply ok 96 getattr ERROR: Request couldn't be completed in time

I guess that's NFS4ERR_DELAY?  (Wireshark would show the details.)

> server: 10.110.96.90
> client: 10.110.96.112
> 
> status of nfs services:
> 
> nfslock: running
> rpcbind: running
> rpcidmapd: stopped
> 
> this happens with a centos 6 _and_ a centos 7 client (both KVM).
> NFS 3 mount from the same host don't work either.
> 
> other kvm guests (centos 6) on the same physical host can mount the
> share with no problem.
> 
> the netapp admin tells me there's "no problem" on his side.

I think that needs to be looked into in more detail.

--b.

> iptables is disabled of course.
> 
> ###
> 
> what could be the problem on my (client) side?
> could this be a kvm problem?
> 
> kvm host is centos 6.
> network mode is "bridge".
> network driver is "virtio".
> 
> thx for any advice
> matthias
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
